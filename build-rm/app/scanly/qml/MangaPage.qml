import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import app.scanly

Page {
    id: page
    property string mangaId
    property string mangaTitle
    property string coverUrl: ""
    property var chapters: []
    property bool followed: libraryStore.isFollowed(mangaId)
    property var downloadStates: ({})
    property string searchQuery: ""
    property bool keyboardOpen: false
    property bool mostRecentFirst: false
    property string providerName: ""
    property var metadata: ({})
    property bool descriptionExpanded: false
    readonly property bool offline: !device.online || settings.offlineMode
    readonly property string downloadedCover: downloads.coverPathFor(mangaId)
    readonly property string displayDescription: metadata.description || ""
    property int fallbackGen: 0
    readonly property string fallbackCoverUrl: (fallbackGen, source.fallbackCoverFor(mangaId))
    readonly property string displayCover: (metadata.coverUrl && metadata.coverUrl !== "")
        ? metadata.coverUrl
        : (fallbackCoverUrl !== ""
            ? fallbackCoverUrl
            : (page.offline && downloadedCover !== ""
                ? downloadedCover
                : page.coverUrl))

    function ensureFollowed() {
        if (!page.followed) {
            libraryStore.follow(page.mangaId, page.mangaTitle, page.displayCover)
            page.followed = true
        }
    }
    property var pageCountByChapter: ({})
    property var pageCountQueue: []
    property int pageCountInFlight: 0
    readonly property int pageCountMaxConcurrent: 3

    function requestPageCount(cid) {
        if (!cid) return
        // WeebCentral chapters are always short manga chapters (~50 pages),
        // never long-form "Book". Skip the per-chapter probe, it would
        // cost one HTTP per chapter on scroll.
        if (cid.startsWith("weebcentral:")) return
        if (downloads.isDownloaded(cid)) return
        if (page.pageCountByChapter[cid] !== undefined) return
        if (page.pageCountQueue.indexOf(cid) !== -1) return
        page.pageCountQueue.push(cid)
        page.pumpPageCountQueue()
    }

    function pumpPageCountQueue() {
        while (page.pageCountInFlight < page.pageCountMaxConcurrent
               && page.pageCountQueue.length > 0) {
            const cid = page.pageCountQueue.shift()
            page.pageCountInFlight++
            source.fetchChapterPages(cid)
        }
    }

    background: Rectangle { color: Theme.paper }

    function offlineChapters() {
        const dl = downloads.downloadedChaptersFor(page.mangaId)
        const out = []
        for (var i = 0; i < dl.length; i++) {
            const c = dl[i]
            out.push({
                id: c.chapterId,
                attributes: {
                    chapter: c.chapterNumber || "",
                    title: c.chapterTitle || "",
                    translatedLanguage: "",
                    externalUrl: "",
                },
                relationships: [],
            })
        }
        return out
    }

    function refetch() {
        if (page.offline) {
            page.chapters = offlineChapters()
            return
        }
        source.fetchChapters(mangaId, settings.preferredLanguages)
    }
    Component.onCompleted: {
        refetch()
        page.metadata = meta.metadataFor(mangaId)
        if (!page.offline)
            meta.fetchMetadata(mangaId, mangaTitle)
    }

    Connections {
        target: device
        function onChanged() {
            if (page.offline) page.chapters = offlineChapters()
            else page.refetch()
        }
    }
    Connections {
        target: settings
        function onOfflineModeChanged() { page.refetch() }
    }

    Connections {
        target: meta
        function onMetadataReceived(mid) {
            if (mid !== page.mangaId) return
            page.metadata = meta.metadataFor(mid)
            if (!page.metadata.coverUrl || page.metadata.coverUrl === "")
                source.fetchFallbackCover(mangaId)
        }
    }

    Connections {
        target: source
        function onFallbackCoverReceived(mid, url) {
            if (mid === page.mangaId) page.fallbackGen++
        }
    }

    Connections {
        target: source
        function onChaptersReceived(arr) {
            page.chapters = arr
            page.providerName = page.providerFromChapters(arr)
        }
        function onChapterPagesReceived(cid, urls) {
            if (page.pageCountByChapter[cid] !== undefined) return
            const m = Object.assign({}, page.pageCountByChapter)
            m[cid] = urls.length
            page.pageCountByChapter = m
            page.pageCountInFlight = Math.max(0, page.pageCountInFlight - 1)
            page.pumpPageCountQueue()
        }
    }
    Connections {
        target: settings
        function onPreferredLanguagesChanged() { page.refetch() }
    }

    function orderedChapters(list) {
        if (!page.mostRecentFirst)
            return list
        const out = []
        for (var i = list.length - 1; i >= 0; i--)
            out.push(list[i])
        return out
    }

    function filteredChapters() {
        if (searchQuery === "") return page.orderedChapters(chapters)
        const q = searchQuery.toLowerCase()
        const out = []
        for (var i = 0; i < chapters.length; i++) {
            const c = chapters[i]
            const num = (c.attributes.chapter || "").toLowerCase()
            const tit = (c.attributes.title || "").toLowerCase()
            if (num.indexOf(q) !== -1 || tit.indexOf(q) !== -1)
                out.push(c)
        }
        return page.orderedChapters(out)
    }
    function providerFromChapters(list) {
        if (!list || list.length === 0) return ""
        const rels = list[0].relationships || []
        for (var i = 0; i < rels.length; i++) {
            if (rels[i].type === "scanlation_group")
                return (rels[i].attributes && rels[i].attributes.name) || ""
        }
        return ""
    }
    property int downloadGen: 0
    Connections {
        target: downloads
        function onChapterDownloadProgress(cid, done, total) {
            const s = Object.assign({}, page.downloadStates)
            s[cid] = { state: "downloading", progress: done / total }
            page.downloadStates = s
        }
        function onChapterDownloadFinished(cid) {
            const s = Object.assign({}, page.downloadStates)
            s[cid] = { state: "downloaded" }
            page.downloadStates = s
            page.downloadGen++
        }
        function onChapterRemoved(cid) {
            const s = Object.assign({}, page.downloadStates)
            delete s[cid]
            page.downloadStates = s
            page.downloadGen++
        }
        function onManifestChanged() { page.downloadGen++ }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 48
        anchors.rightMargin: 48
        anchors.topMargin: 22
        anchors.bottomMargin: page.keyboardOpen ? chapterKeyboard.height : 0
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 22
            spacing: 32

            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                spacing: 10
                MangaCover {
                    id: heroCover
                    Layout.preferredWidth: 240
                    Layout.preferredHeight: Math.round(240 * heroCover.nativeAspect)
                    title: page.mangaTitle
                    imageSource: page.displayCover
                    showLabel: false
                }
                Item {
                    Layout.preferredWidth: 240
                    Layout.preferredHeight: 60
                    Rectangle {
                        anchors.fill: parent
                        color: Theme.ink
                        Text {
                            anchors.centerIn: parent
                            text: "CONTINUE  →"
                            font.family: Theme.mono
                            font.pixelSize: 22
                            font.letterSpacing: 1.2
                            color: Theme.paper
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: page.chapters.length > 0
                        onClicked: app.openReader(page.mangaId, page.mangaTitle,
                                                   page.chapters[0].id, 0)
                    }
                }
                RowLayout {
                    Layout.preferredWidth: 240
                    spacing: 10
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: Theme.ink
                            border.width: 2
                            Text {
                                anchors.centerIn: parent
                                text: "DL ALL"
                                font.family: Theme.mono
                                font.pixelSize: 20
                                font.letterSpacing: 1.0
                                color: Theme.ink
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                page.ensureFollowed()
                                const s = Object.assign({}, page.downloadStates)
                                for (var i = 0; i < page.chapters.length; i++) {
                                    var c = page.chapters[i]
                                    if (!downloads.isDownloaded(c.id))
                                        s[c.id] = { state: "downloading", progress: 0 }
                                }
                                page.downloadStates = s
                                for (var j = 0; j < page.chapters.length; j++) {
                                    var c2 = page.chapters[j]
                                    downloads.downloadChapter(c2.id, page.mangaId, page.mangaTitle,
                                        c2.attributes.title || "", c2.attributes.chapter || "",
                                        page.displayCover)
                                }
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        Rectangle {
                            anchors.fill: parent
                            color: page.followed ? Theme.ink : "transparent"
                            border.color: Theme.ink
                            border.width: 2
                            Text {
                                anchors.centerIn: parent
                                text: page.followed ? "SAVED" : "SAVE"
                                font.family: Theme.mono
                                font.pixelSize: 20
                                font.letterSpacing: 1.0
                                color: page.followed ? Theme.paper : Theme.ink
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (page.followed) { libraryStore.unfollow(page.mangaId); page.followed = false }
                                else { libraryStore.follow(page.mangaId, page.mangaTitle, page.displayCover); page.followed = true }
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 4

                Text {
                    text: "SCAN MIRRORS · " + page.chapters.length + " CHAPTERS"
                    font.family: Theme.mono
                    font.pixelSize: 20
                    font.letterSpacing: 1.2
                    color: Theme.inkMute
                }
                Text {
                    text: page.mangaTitle
                    font.family: Theme.serif
                    font.italic: true
                    font.weight: Font.Medium
                    font.pixelSize: 93
                    font.letterSpacing: 0
                    color: Theme.ink
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    lineHeight: 0.92
                }
                Item {
                    Layout.fillWidth: true
                    Layout.topMargin: 14
                    implicitHeight: 108

                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 2
                        color: Theme.ink
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 2
                        color: Theme.ink
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        spacing: 0

                        Repeater {
                            model: [
                                { k: "Chapters", v: String(page.chapters.length) },
                                { k: "Language", v: source.languageForId(page.mangaId) },
                                { k: "Source",   v: page.providerName !== "" ? page.providerName : "Scan mirrors" },
                            ]
                            delegate: ColumnLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.leftMargin: 18
                                Layout.topMargin: 14
                                Layout.bottomMargin: 14
                                spacing: 6
                                Text {
                                    text: modelData.k.toUpperCase()
                                    font.family: Theme.mono
                                    font.pixelSize: 18
                                    font.letterSpacing: 1.0
                                    color: Theme.inkMute
                                }
                                Text {
                                    text: modelData.v
                                    font.family: Theme.serif
                                    font.pixelSize: 34
                                    font.weight: Font.DemiBold
                                    color: Theme.ink
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 14
                    spacing: 6

                    Text {
                        id: synopsisText
                        Layout.fillWidth: true
                        text: page.displayDescription !== ""
                            ? page.displayDescription
                                  .split(/\n\s*-{3,}\s*\n|\n\s*\*{3,}\s*\n|\n?\s*Notes?\s*:/i)[0]
                                  .replace(/\s*\n+\s*/g, " ")
                                  .trim()
                            : (page.offline
                                ? "Offline · no cached synopsis."
                                : (page.metadata.fetched
                                    ? "No synopsis available."
                                    : "Fetching synopsis from MangaDex…"))
                        font.family: Theme.serif
                        font.italic: page.displayDescription === ""
                        font.pixelSize: 27
                        color: page.displayDescription === "" ? Theme.inkMute : Theme.inkSoft
                        wrapMode: Text.WordWrap
                        lineHeight: 1.25
                        maximumLineCount: page.descriptionExpanded ? 999 : 5
                        elide: page.descriptionExpanded ? Text.ElideNone : Text.ElideRight
                        textFormat: Text.PlainText
                    }

                    Item {
                        visible: page.displayDescription !== "" && synopsisText.truncated
                                 || page.descriptionExpanded
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: toggleLabel.implicitWidth + 4

                        Text {
                            id: toggleLabel
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: page.descriptionExpanded ? "SHOW LESS  ▲" : "READ MORE  ▼"
                            font.family: Theme.mono
                            font.pixelSize: 18
                            font.letterSpacing: 1.0
                            color: Theme.accent
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -10
                            onClicked: {
                                page.descriptionExpanded = !page.descriptionExpanded
                                epaper.partialRefresh()
                            }
                        }
                    }
                }

                Flow {
                    Layout.fillWidth: true
                    Layout.topMargin: 14
                    spacing: 6
                    Repeater {
                        model: (page.metadata.tags && page.metadata.tags.length > 0)
                            ? page.metadata.tags.slice(0, 8)
                            : []
                        delegate: Item {
                            width: tag.implicitWidth + 24
                            height: 34
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: Theme.ink
                                border.width: 2
                            }
                            Text {
                                id: tag
                                anchors.centerIn: parent
                                text: modelData
                                font.family: Theme.mono
                                font.pixelSize: 18
                                font.letterSpacing: 0.4
                                color: Theme.ink
                            }
                        }
                    }
                }
            }
        }

        Hairline { Layout.fillWidth: true; strength: 1.0 }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 18
            Layout.bottomMargin: 10
            Text {
                text: "Chapters"
                font.family: Theme.serif
                font.italic: true
                font.weight: Font.DemiBold
                font.pixelSize: 44
                color: Theme.ink
            }
            Text {
                Layout.leftMargin: 12
                text: (page.searchQuery === "" ? page.chapters.length
                       : page.filteredChapters().length + " / " + page.chapters.length)
                       + " CHAPTERS"
                font.family: Theme.mono
                font.pixelSize: 20
                font.letterSpacing: 1.0
                color: Theme.inkMute
            }
            Item { Layout.fillWidth: true }
            Item {
                Layout.preferredWidth: sortLabel.implicitWidth + 28
                Layout.preferredHeight: 46
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: Theme.ink
                    border.width: 2
                }
                Text {
                    id: sortLabel
                    anchors.centerIn: parent
                    text: page.mostRecentFirst ? "MOST RECENT" : "OLDEST FIRST"
                    font.family: Theme.mono
                    font.pixelSize: 20
                    font.letterSpacing: 1.0
                    color: Theme.inkSoft
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        page.mostRecentFirst = !page.mostRecentFirst
                        chList.positionViewAtBeginning()
                        epaper.partialRefresh()
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            Layout.bottomMargin: 8

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                color: Theme.ink
                opacity: 1
            }
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                color: Theme.ink
                opacity: 1
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 4
                spacing: 10

                Canvas {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    Layout.alignment: Qt.AlignVCenter
                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.reset()
                        ctx.strokeStyle = Theme.inkMute
                        ctx.lineWidth = 2.4
                        ctx.lineCap = "square"
                        ctx.beginPath()
                        ctx.arc(13, 13, 8, 0, Math.PI * 2)
                        ctx.stroke()
                        ctx.beginPath()
                        ctx.moveTo(20, 20)
                        ctx.lineTo(29, 29)
                        ctx.stroke()
                    }
                }
                TextField {
                    id: chapterSearch
                    Layout.fillWidth: true
                    placeholderText: "Search chapters (number or title)…"
                    font.family: Theme.serif
                    font.italic: true
                    font.pixelSize: 31
                    color: Theme.ink
                    placeholderTextColor: Theme.inkFaint
                    background: Item {}
                    inputMethodHints: Qt.ImhNoPredictiveText
                    onPressed: page.keyboardOpen = true
                    onActiveFocusChanged: {
                        if (activeFocus)
                            page.keyboardOpen = true
                    }
                    onAccepted: {
                        page.keyboardOpen = false
                        chapterSearch.focus = false
                        epaper.partialRefresh()
                    }
                    onTextChanged: page.searchQuery = text
                }
                Item {
                    visible: page.searchQuery !== ""
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    Canvas {
                        anchors.centerIn: parent
                        width: 22
                        height: 22
                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.reset()
                            ctx.strokeStyle = Theme.inkMute
                            ctx.lineWidth = 2.2
                            ctx.lineCap = "square"
                            ctx.beginPath()
                            ctx.moveTo(4, 4)
                            ctx.lineTo(width - 4, height - 4)
                            ctx.moveTo(width - 4, 4)
                            ctx.lineTo(4, height - 4)
                            ctx.stroke()
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { chapterSearch.text = ""; page.searchQuery = "" }
                    }
                }
            }
        }

        ListView {
            id: chList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: page.filteredChapters()
            clip: true

            delegate: Item {
                id: ch
                required property var modelData
                required property int index
                width: ListView.view.width
                height: 84

                readonly property string chId: modelData.id
                readonly property string chNum: modelData.attributes.chapter || ", "
                readonly property int localPageCount: (page.downloadGen, downloads.isDownloaded(chId)
                    ? downloads.localPagesFor(chId).length : 0)
                readonly property int knownPageCount: page.pageCountByChapter[chId] !== undefined
                    ? page.pageCountByChapter[chId]
                    : localPageCount
                readonly property bool isBook: knownPageCount > 80
                readonly property string chTitle: modelData.attributes.title
                    || ((isBook ? "Book " : "Chapter ") + chNum)

                Component.onCompleted: page.requestPageCount(chId)
                readonly property string chLang: (modelData.attributes.translatedLanguage || "").toUpperCase()
                readonly property string chExternal: modelData.attributes.externalUrl || ""
                readonly property bool isExternal: chExternal !== ""
                readonly property var dl: page.downloadStates[chId]
                readonly property bool isDownloaded: (page.downloadGen, downloads.isDownloaded(chId))
                readonly property bool isDownloading: !!dl && dl.state === "downloading"

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 2
                    color: Theme.ink
                    opacity: 1
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 20

                    Text {
                        Layout.preferredWidth: 70
                        text: ch.chNum
                        font.family: Theme.mono
                        font.pixelSize: 24
                        color: Theme.ink
                        font.letterSpacing: 0.5
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Text {
                                text: ch.chTitle !== "" ? ch.chTitle : ", "
                                font.family: Theme.serif
                                font.pixelSize: 32
                                font.italic: ch.chTitle === ""
                                color: ch.isExternal ? Theme.inkSoft : Theme.ink
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 136
                        Layout.preferredHeight: 44

                        Text {
                            visible: ch.isExternal
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: "↗  OPEN"
                            font.family: Theme.mono
                            font.pixelSize: 19
                            font.letterSpacing: 1.0
                            color: Theme.accent
                        }
                        Canvas {
                            visible: !ch.isExternal && ch.isDownloaded
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 24
                            height: 20
                            onPaint: {
                                const ctx = getContext("2d")
                                ctx.reset()
                                ctx.strokeStyle = Theme.ink
                                ctx.lineWidth = 2.6
                                ctx.lineCap = "square"
                                ctx.lineJoin = "miter"
                                ctx.beginPath()
                                ctx.moveTo(2, 10)
                                ctx.lineTo(9, 17)
                                ctx.lineTo(width - 2, 2)
                                ctx.stroke()
                            }
                        }

                        Item {
                            id: trashBtn
                            visible: !ch.isExternal && ch.isDownloaded
                            z: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 48
                            anchors.verticalCenter: parent.verticalCenter
                            width: 44
                            height: 44
                            Canvas {
                                anchors.centerIn: parent
                                width: 22
                                height: 24
                                onPaint: {
                                    const ctx = getContext("2d")
                                    ctx.reset()
                                    ctx.strokeStyle = Theme.inkSoft
                                    ctx.lineWidth = 2.0
                                    ctx.lineCap = "square"
                                    ctx.lineJoin = "miter"
                                    // lid
                                    ctx.beginPath()
                                    ctx.moveTo(1, 6); ctx.lineTo(width - 1, 6)
                                    ctx.moveTo(7, 6); ctx.lineTo(7, 2); ctx.lineTo(width - 7, 2); ctx.lineTo(width - 7, 6)
                                    ctx.stroke()
                                    // body
                                    ctx.beginPath()
                                    ctx.moveTo(3, 8); ctx.lineTo(5, height - 1); ctx.lineTo(width - 5, height - 1); ctx.lineTo(width - 3, 8)
                                    ctx.stroke()
                                    // lines
                                    ctx.beginPath()
                                    ctx.moveTo(8,  11); ctx.lineTo(8,  height - 4)
                                    ctx.moveTo(width / 2, 11); ctx.lineTo(width / 2, height - 4)
                                    ctx.moveTo(width - 8, 11); ctx.lineTo(width - 8, height - 4)
                                    ctx.stroke()
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                z: 3
                                onClicked: downloads.removeChapter(ch.chId)
                            }
                        }
                        Canvas {
                            visible: !ch.isExternal && !ch.isDownloaded && !ch.isDownloading
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 28
                            height: 28
                            onPaint: {
                                const ctx = getContext("2d")
                                ctx.reset()
                                ctx.strokeStyle = Theme.inkSoft
                                ctx.lineWidth = 2.8
                                ctx.lineCap = "square"
                                ctx.lineJoin = "miter"
                                ctx.beginPath()
                                ctx.moveTo(width / 2, 3)
                                ctx.lineTo(width / 2, 17)
                                ctx.moveTo(7, 12)
                                ctx.lineTo(width / 2, 20)
                                ctx.lineTo(width - 7, 12)
                                ctx.moveTo(5, height - 4)
                                ctx.lineTo(width - 5, height - 4)
                                ctx.stroke()
                            }
                        }
                        Column {
                            visible: ch.isDownloading
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 96
                            spacing: 5
                            Text {
                                anchors.right: parent.right
                                text: Math.round((ch.dl ? ch.dl.progress : 0) * 100) + "%"
                                font.family: Theme.mono
                                font.pixelSize: 20
                                color: Theme.ink
                            }
                            Rectangle {
                                width: 96; height: 5
                                color: Theme.paperEdge
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: parent.width * (ch.dl ? ch.dl.progress : 0)
                                    color: Theme.ink
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (ch.isExternal)
                                    Qt.openUrlExternally(ch.chExternal)
                                else if (!ch.isDownloaded && !ch.isDownloading) {
                                    page.ensureFollowed()
                                    const s = Object.assign({}, page.downloadStates)
                                    s[ch.chId] = { state: "downloading", progress: 0 }
                                    page.downloadStates = s
                                    downloads.downloadChapter(ch.chId, page.mangaId, page.mangaTitle,
                                        ch.chTitle, ch.chNum, page.displayCover)
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: -1
                    onClicked: {
                        if (ch.isExternal)
                            Qt.openUrlExternally(ch.chExternal)
                        else
                            app.openReader(page.mangaId, page.mangaTitle, ch.chId, 0)
                    }
                }
            }
        }
    }

    OnScreenKeyboard {
        id: chapterKeyboard
        target: chapterSearch
        visible: page.keyboardOpen
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: visible ? implicitHeight : 0
        onAccepted: {
            page.keyboardOpen = false
            chapterSearch.focus = false
            epaper.partialRefresh()
        }
        onDismissed: {
            page.keyboardOpen = false
            chapterSearch.focus = false
            epaper.partialRefresh()
        }
    }
}
