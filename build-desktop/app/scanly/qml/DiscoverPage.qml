import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import app.scanly

Page {
    id: page
    signal openManga(string id, string title, string coverUrl)

    background: Rectangle { color: Theme.paper }

    property string lastError: ""
    property bool keyboardOpen: search.activeFocus
    property var metaByManga: ({})
    property var metaQueue: []
    property int metaInFlight: 0
    readonly property int metaMaxConcurrent: 3

    function requestMeta(mid, title) {
        if (!mid || !title) return
        if (page.metaByManga[mid] !== undefined) return
        for (var i = 0; i < page.metaQueue.length; i++)
            if (page.metaQueue[i].mid === mid) return
        page.metaQueue.push({ mid: mid, title: title })
        page.pumpMetaQueue()
    }

    function pumpMetaQueue() {
        while (page.metaInFlight < page.metaMaxConcurrent
               && page.metaQueue.length > 0) {
            const job = page.metaQueue.shift()
            page.metaInFlight++
            const cached = meta.metadataFor(job.mid)
            if (cached && cached.fetched) {
                page.applyMeta(job.mid, cached)
                continue
            }
            meta.fetchMetadata(job.mid, job.title)
        }
    }

    property var fallbackCoverByManga: ({})

    function applyMeta(mid, m) {
        const copy = Object.assign({}, page.metaByManga)
        copy[mid] = m || { fetched: true }
        page.metaByManga = copy
        page.metaInFlight = Math.max(0, page.metaInFlight - 1)
        page.pumpMetaQueue()
        // If MangaDex didn't yield a cover for a WeebCentral result, ask
        // the router to scrape the WC series page for one.
        const noCover = !copy[mid] || !copy[mid].coverUrl || copy[mid].coverUrl === ""
        if (noCover && mid.indexOf("weebcentral:") === 0)
            source.fetchFallbackCover(mid)
    }

    Connections {
        target: source
        function onErrorOccurred(msg) { page.lastError = msg }
        function onFallbackCoverReceived(mid, url) {
            const copy = Object.assign({}, page.fallbackCoverByManga)
            copy[mid] = url
            page.fallbackCoverByManga = copy
        }
    }

    Connections {
        target: meta
        function onMetadataReceived(mid) {
            if (page.metaByManga[mid] === undefined)
                page.applyMeta(mid, meta.metadataFor(mid))
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 48
        anchors.rightMargin: 48
        anchors.topMargin: 24
        anchors.bottomMargin: page.keyboardOpen ? keyboardPanel.height : 0
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 18

            ColumnLayout {
                spacing: 2
                Text {
                    text: "Discover"
                    font.family: Theme.serif
                    font.italic: true
                    font.weight: Font.Medium
                    font.pixelSize: 72
                    font.letterSpacing: 0
                    color: Theme.ink
                }
            }

            Item { Layout.fillWidth: true }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 70

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 3
                color: Theme.ink
            }
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 3
                color: Theme.ink
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                spacing: 14

                Canvas {
                    width: 26; height: 26
                    Layout.alignment: Qt.AlignVCenter
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.strokeStyle = Theme.ink;
                        ctx.lineWidth = 1.4;
                        ctx.beginPath();
                        ctx.arc(7, 7, 5, 0, 2 * Math.PI);
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.moveTo(11, 11); ctx.lineTo(16, 16);
                        ctx.stroke();
                    }
                }
                TextField {
                    id: search
                    Layout.fillWidth: true
                    placeholderText: "Search by title…"
                    font.family: Theme.serif
                    font.italic: true
                    font.pixelSize: 36
                    color: Theme.ink
                    placeholderTextColor: Theme.inkFaint
                    background: Item {}
                    inputMethodHints: Qt.ImhNoPredictiveText
                    onPressed: page.keyboardOpen = true
                    onActiveFocusChanged: {
                        if (activeFocus)
                            page.keyboardOpen = true
                    }
                    onAccepted: page.doSearch()
                }
                Text {
                    visible: search.text === ""
                    text: "TAP TO TYPE"
                    font.family: Theme.mono
                    font.pixelSize: 20
                    font.letterSpacing: 1.0
                    color: Theme.inkMute
                }
            }
        }


        Rectangle {
            visible: page.lastError !== ""
            Layout.fillWidth: true
            color: "transparent"
            border.color: Theme.seal
            border.width: 1
            Layout.preferredHeight: errLine.implicitHeight + 20
            Layout.bottomMargin: 12
            Text {
                id: errLine
                anchors.fill: parent
                anchors.margins: 10
                text: "ERROR  " + page.lastError
                font.family: Theme.mono
                font.pixelSize: 22
                color: Theme.seal
                wrapMode: Text.WordWrap
            }
        }


        ListView {
            id: results
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 10
            model: searchModel
            spacing: 0
            clip: true
            cacheBuffer: 2400

            ColumnLayout {
                visible: results.count === 0
                anchors.centerIn: parent
                width: parent.width * 0.7
                spacing: 16

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Find your next read"
                    font.family: Theme.serif
                    font.italic: true
                    font.pixelSize: 64
                    color: Theme.inkSoft
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    Layout.fillWidth: true
                    text: "Search any manga title above to browse the catalogue from the sources you have enabled."
                    font.family: Theme.serif
                    font.pixelSize: 30
                    color: Theme.inkMute
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    lineHeight: 1.25
                }
            }

            delegate: Item {
                id: row
                required property string mangaId
                required property string title
                required property string coverUrl
                required property string description
                required property int index

                readonly property var meta: page.metaByManga[mangaId]
                readonly property string fallbackCover: page.fallbackCoverByManga[mangaId] || ""
                readonly property string displayCover: (meta && meta.coverUrl && meta.coverUrl !== "")
                    ? meta.coverUrl
                    : (fallbackCover !== "" ? fallbackCover : row.coverUrl)
                readonly property string displayDescription: (meta && meta.description && meta.description !== "")
                    ? meta.description
                          .split(/\n\s*-{3,}\s*\n|\n\s*\*{3,}\s*\n|\n?\s*Notes?\s*:/i)[0]
                          .replace(/\s*\n+\s*/g, " ").trim()
                    : row.description

                Component.onCompleted: page.requestMeta(mangaId, title)

                width: ListView.view.width
                height: 220

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
                    anchors.topMargin: 18
                    anchors.bottomMargin: 18
                    spacing: 26

                    MangaCover {
                        Layout.preferredWidth: 132
                        Layout.preferredHeight: 184
                        title: row.title
                        imageSource: row.displayCover
                        dense: true
                        showLabel: false
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 6
                        Text {
                            text: row.title
                            font.family: Theme.serif
                            font.pixelSize: 52
                            font.weight: Font.DemiBold
                            color: Theme.ink
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: row.description.length > 0
                                ? row.description
                                : "No synopsis available."
                            font.family: Theme.serif
                            font.italic: true
                            font.pixelSize: 30
                            color: Theme.inkMute
                            elide: Text.ElideRight
                            maximumLineCount: 3
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            lineHeight: 1.15
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: page.openManga(row.mangaId, row.title, row.displayCover)
                }
            }
        }
    }

    OnScreenKeyboard {
        id: keyboardPanel
        target: search
        visible: page.keyboardOpen
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: visible ? implicitHeight : 0
        onAccepted: page.doSearch()
        onDismissed: {
            page.keyboardOpen = false
            search.focus = false
            epaper.partialRefresh()
        }
    }

    function doSearch() {
        page.lastError = ""
        source.searchManga(search.text)
        page.keyboardOpen = false
        search.focus = false
        epaper.partialRefresh()
    }
}
