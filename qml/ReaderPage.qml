import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import app.scanly

Page {
    id: page
    property string mangaId
    property string mangaTitle
    property string chapterId
    property int startPage: 0
    property var pageUrls: []
    property int currentPage: 0
    property bool chromeVisible: false
    // Per-session orientation freeze: when locked, ignore the accelerometer
    // and keep whatever rotation/spread we captured at lock time.
    property bool orientationLocked: false
    property int  lockedRotation: 0
    property bool lockedLandscape: false

    // Under AppLoad, xochitl is locked to Portrait by main.cpp, so the same
    // QML rotation works in both runtimes.
    property int displayRotation: orientationLocked
        ? lockedRotation
        : (device.landscape ? device.rotationAngle : 0)
    property bool landscapeSpread: orientationLocked
        ? lockedLandscape
        : (device.landscape || width > height)

    function toggleOrientationLock() {
        if (page.orientationLocked) {
            page.orientationLocked = false
        } else {
            page.lockedRotation  = device.landscape ? device.rotationAngle : 0
            page.lockedLandscape = device.landscape || width > height
            page.orientationLocked = true
        }
    }
    property int spreadSize: landscapeSpread ? 2 : 1
    // Per-page natural aspect ratio (w/h). Recorded as each Image loads so we
    // can collapse a 2-page spread to a single full-screen frame whenever the
    // underlying scan is itself landscape (e.g. a double-page panel).
    property var pageAspects: ({})
    property int aspectGeneration: 0

    function recordAspect(idx, w, h) {
        if (!w || !h) return
        const ratio = w / h
        if (page.pageAspects[idx] === ratio) return
        page.pageAspects[idx] = ratio
        page.aspectGeneration++
    }

    function isLandscapePage(idx) {
        const r = page.pageAspects[idx]
        return r !== undefined && r > 1.05
    }

    function effectiveSpreadSize() {
        page.aspectGeneration  // dep
        if (!page.landscapeSpread) return 1
        if (page.isLandscapePage(page.currentPage)) return 1
        if (page.currentPage + 1 < page.pageUrls.length
                && page.isLandscapePage(page.currentPage + 1)) return 1
        return 2
    }
    property int chromeMargin: 36
    property int topBarHeight: 76
    property int bottomBarHeight: 120
    property int chromeTextSize: 24
    property int chromeIconSize: 48
    property int pageTurnsSinceGhostClean: 0
    property int ghostCleanInterval: Math.max(1, settings.ghostCleanInterval)
    // Content mode = GC16 every frame, so each page turn is already a full
    // refresh and no ghost accumulates. The flash cadence is only useful for
    // Animation/Mono/Sleep modes (A2/DU waveforms) which leave residue.
    property bool ghostCleanEnabled: settings.forceScreenMode
                                     && settings.screenMode !== "Content"
    // True while waiting for the next page Image to finish loading so we can
    // restore the user's fast waveform only after the GC16 render committed.
    property bool ghostCleanPending: false
    property int imageGeneration: 0
    property var chapterList: []
    property string preloadedNextChapterId: ""

    background: Rectangle { color: Theme.paper }

    onCurrentPageChanged: {
        if (page.mangaId !== "" && libraryStore.isFollowed(page.mangaId))
            libraryStore.updatePosition(page.mangaId, page.chapterId, page.currentPage)
        page.maybePreloadNextChapter()
    }

    function nextChapterId() {
        if (page.chapterList.length === 0) return ""
        for (var i = 0; i < page.chapterList.length; i++) {
            if (page.chapterList[i].id === page.chapterId)
                return (i + 1 < page.chapterList.length) ? page.chapterList[i + 1].id : ""
        }
        return ""
    }

    function maybePreloadNextChapter() {
        if (!settings.autoAdvanceChapter) return
        if (page.pageUrls.length === 0) return
        if (page.visibleLastPage() < page.pageUrls.length - 1) return
        const nextId = page.nextChapterId()
        if (nextId === "" || nextId === page.preloadedNextChapterId) return
        page.preloadedNextChapterId = nextId
        if (downloads.isDownloaded(nextId)) {
            const local = downloads.localPagesFor(nextId)
            for (var i = 0; i < Math.min(2, local.length); i++)
                pageImages.displayUrl(local[i])
        } else {
            source.fetchChapterPages(nextId)
        }
    }

    function goToPage(index) {
        if (page.pageUrls.length <= 0)
            return

        const next = Math.max(0, Math.min(page.pageUrls.length - 1, index))
        if (next === page.currentPage)
            return

        // If the user taps during the ghost-clean restore window, kill the
        // pending restore and put the mode back to user immediately so this
        // tap uses the fast waveform instead of GC16.
        if (page.ghostCleanPending) {
            page.ghostCleanPending = false
            ghostRestoreTimer.stop()
            page.applyAppLoadScreenMode()
        }

        const turnedPages = Math.abs(next - page.currentPage)

        // Ghost-clean cadence under AppLoad: switch the linuxfb mode to
        // Content (GC16) right before the page change so this single page
        // turn renders the new image under a full grayscale waveform across
        // the image area = ghost cleared. Restore the user's fast mode after
        // the GC16 frame has time to commit.
        let cleanThisTurn = false
        if (page.ghostCleanEnabled) {
            page.pageTurnsSinceGhostClean += turnedPages
            if (page.pageTurnsSinceGhostClean >= page.ghostCleanInterval) {
                page.pageTurnsSinceGhostClean = 0
                cleanThisTurn = true
            }
        }

        if (cleanThisTurn) {
            // Under AppLoad, do NOT call epaper.clearGhosting(): it sets the
            // forceFull flag which makes the next ioctl emit UPDATE_MODE_FULL
            // + ENABLE_INVERSION + GC16 on the full screen, the EPDC then
            // needs ~1s+ to recover, blocking the next page turn. Just switch
            // the waveform to Content (GC16, PARTIAL) which produces the same
            // visible refresh as permanent Content mode without the heavy
            // post-refresh recovery.
            epaper.setAppLoadRefreshMode("Content")
            page.ghostCleanPending = true  // Image.onStatusChanged restores
        } else {
            epaper.partialRefresh()
        }

        page.currentPage = next
    }

    Timer {
        id: ghostRestoreTimer
        interval: 80  // just long enough for the GC16 ioctl to fire after
                      // Image.Ready; the EPDC commits the waveform on its
                      // own clock so we don't need to block the mode window
        repeat: false
        onTriggered: {
            page.ghostCleanPending = false
            page.applyAppLoadScreenMode()
        }
    }

    function visiblePageIndexes() {
        // Order is current-page first, then next-page. The spread RowLayout
        // is laid out RTL when in landscape so the current page lands on the
        // right (manga reading order) and gets created/loaded first.
        const indexes = []
        const size = page.effectiveSpreadSize()
        for (let i = 0; i < size; i++) {
            const idx = page.currentPage + i
            if (idx < page.pageUrls.length)
                indexes.push(idx)
        }
        return indexes
    }

    function visibleLastPage() {
        return Math.min(page.pageUrls.length - 1,
                        page.currentPage + page.effectiveSpreadSize() - 1)
    }

    function chapterLabel() {
        const prefix = page.pageUrls.length > 80 ? "BK. " : "CH. "
        // 1. Source-provided number (most reliable, especially for
        //    opaque-ID sources like WeebCentral).
        for (var i = 0; i < page.chapterList.length; i++) {
            if (page.chapterList[i].id === page.chapterId) {
                const num = page.chapterList[i].attributes.chapter
                if (num && num !== "") return prefix + num
                break
            }
        }
        // 2. Fallback: parse the slug (SushiScan-style IDs).
        const named = page.chapterId.match(/(?:chapitre|chapter)-([0-9]+(?:[.-][0-9]+)?)/i)
        if (named && named.length > 1)
            return prefix + named[1].replace("-", ".")
        const tail = page.chapterId.match(/(?:%2F|\/)([0-9]+(?:[.\-][0-9]+)?)(?:%2F|\/)?$/i)
        if (tail && tail.length > 1)
            return prefix + tail[1].replace("-", ".")
        return prefix.trim()
    }

    function pageRangeLabel() {
        if (page.pageUrls.length <= 0)
            return "0"

        const first = page.currentPage + 1
        const last = page.visibleLastPage() + 1
        return first === last ? String(first) : first + "-" + last
    }

    function displaySource(url, generation) {
        generation
        return pageImages.displayUrl(url)
    }

    function applyAppLoadScreenMode() {
        if (settings.forceScreenMode)
            epaper.setAppLoadRefreshMode(settings.screenMode)
        else
            epaper.resetAppLoadRefreshMode()
    }

    function loadChapter(cid, startIdx) {
        page.chapterId = cid
        page.startPage = startIdx || 0
        page.currentPage = 0
        page.pageUrls = []
        page.pageAspects = ({})
        page.aspectGeneration++
        page.pageTurnsSinceGhostClean = 0
        page.preloadedNextChapterId = ""
        if (downloads.isDownloaded(cid)) {
            const local = downloads.localPagesFor(cid)
            page.pageUrls = local
            page.currentPage = Math.min(page.startPage, Math.max(0, local.length - 1))
        } else {
            source.fetchChapterPages(cid)
        }
    }

    function advanceForward() {
        const onLast = page.visibleLastPage() >= page.pageUrls.length - 1
        if (onLast && settings.autoAdvanceChapter && page.pageUrls.length > 0) {
            if (page.advanceToNextChapter()) return
        }
        page.goToPage(page.currentPage + page.effectiveSpreadSize())
    }

    function advanceBackward() {
        // If the page just before us is a landscape spread, step back by 1
        // so we land on it alone, not paired with a neighbour.
        var step = page.landscapeSpread ? 2 : 1
        if (page.currentPage - 1 >= 0 && page.isLandscapePage(page.currentPage - 1))
            step = 1
        page.goToPage(page.currentPage - step)
    }

    function advanceToNextChapter() {
        if (page.chapterList.length === 0) return false
        var idx = -1
        for (var i = 0; i < page.chapterList.length; i++) {
            if (page.chapterList[i].id === page.chapterId) { idx = i; break }
        }
        if (idx < 0 || idx + 1 >= page.chapterList.length) return false
        const next = page.chapterList[idx + 1]
        page.mangaTitle = page.mangaTitle
        page.loadChapter(next.id, 0)
        return true
    }

    Component.onCompleted: {
        page.applyAppLoadScreenMode()
        loadChapter(page.chapterId, page.startPage)
        if (page.mangaId !== "")
            source.fetchChapters(page.mangaId, settings.preferredLanguages)
    }

    Component.onDestruction: epaper.resetAppLoadRefreshMode()

    Connections {
        target: source
        function onChapterPagesReceived(cid, urls) {
            if (cid === page.chapterId) {
                page.pageUrls = urls
                pageImages.prepare(urls)
                page.currentPage = Math.min(page.startPage, Math.max(0, urls.length - 1))
            } else if (cid === page.preloadedNextChapterId) {
                for (var i = 0; i < Math.min(2, urls.length); i++)
                    pageImages.displayUrl(urls[i])
            }
        }
        function onChaptersReceived(arr) {
            page.chapterList = arr
            page.maybePreloadNextChapter()
        }
    }

    Connections {
        target: pageImages
        function onChanged() { page.imageGeneration++ }
    }

    Connections {
        target: settings
        function onScreenModeChanged() { page.applyAppLoadScreenMode() }
        function onForceScreenModeChanged() { page.applyAppLoadScreenMode() }
    }

    Item {
        id: readerSurface
        anchors.centerIn: parent
        width: page.displayRotation !== 0 ? page.height : page.width
        height: page.displayRotation !== 0 ? page.width : page.height
        rotation: page.displayRotation

    Item {
        id: topBar
        visible: page.chromeVisible
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: page.chromeVisible ? page.topBarHeight : 0

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: page.chromeMargin
            anchors.rightMargin: page.chromeMargin
            spacing: 20

            Item {
                Layout.preferredWidth: page.chromeIconSize
                Layout.preferredHeight: page.chromeIconSize
                Canvas {
                    anchors.centerIn: parent
                    width: 26
                    height: 26
                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.reset()
                        ctx.strokeStyle = Theme.ink
                        ctx.lineWidth = 2.5
                        ctx.lineCap = "square"
                        ctx.beginPath()
                        ctx.moveTo(4, 4)
                        ctx.lineTo(width - 4, height - 4)
                        ctx.moveTo(width - 4, 4)
                        ctx.lineTo(4, height - 4)
                        ctx.stroke()
                    }
                }
                MouseArea { anchors.fill: parent; onClicked: { epaper.resetAppLoadRefreshMode(); stack.pop(); app.readerOpen = false } }
            }
            Text {
                text: page.mangaTitle.toUpperCase()
                font.family: Theme.mono
                font.pixelSize: page.chromeTextSize
                font.letterSpacing: 1.7
                color: Theme.ink
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: page.chapterLabel() + " · P. " + page.pageRangeLabel()
                font.family: Theme.mono
                font.pixelSize: page.chromeTextSize
                font.letterSpacing: 1.7
                color: Theme.inkMute
                horizontalAlignment: Text.AlignRight
                Layout.maximumWidth: page.landscapeSpread ? 460 : 360
            }

            // Orientation lock toggle. Same closed-lock glyph in both states,
            // only the colour shifts to show whether the lock is engaged.
            Canvas {
                id: lockIcon
                width: 40; height: 40
                Layout.alignment: Qt.AlignVCenter

                Connections {
                    target: page
                    function onOrientationLockedChanged() { lockIcon.requestPaint() }
                }

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    const locked = page.orientationLocked
                    const colour = locked ? Theme.ink : Theme.paperEdge
                    ctx.strokeStyle = colour
                    ctx.lineWidth = 2.4
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"

                    const cx = width / 2
                    const bodyTop = 18
                    const bodyW = 22
                    const bodyH = 16
                    const bx = cx - bodyW / 2

                    if (locked) {
                        ctx.fillStyle = colour
                        ctx.fillRect(bx, bodyTop, bodyW, bodyH)
                    } else {
                        ctx.strokeRect(bx, bodyTop, bodyW, bodyH)
                    }
                    // Keyhole dot
                    ctx.fillStyle = locked ? Theme.paper : colour
                    ctx.beginPath()
                    ctx.arc(cx, bodyTop + bodyH / 2, 2.2, 0, Math.PI * 2)
                    ctx.fill()
                    // Closed shackle in both states
                    ctx.beginPath()
                    ctx.arc(cx, bodyTop, 7, Math.PI, 0)
                    ctx.stroke()
                }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    onClicked: page.toggleOrientationLock()
                }
            }

            // Collapse-chrome icon, frame-brackets, matches the hand-drawn
            // Canvas wifi/battery glyphs in StatusBar.
            Canvas {
                id: collapseIcon
                width: 28; height: 28
                Layout.alignment: Qt.AlignVCenter
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = Theme.inkMute
                    ctx.lineWidth = 1.8
                    ctx.lineCap = "square"
                    const a = 5     // arm length
                    const m = 1     // outer margin
                    // top-left
                    ctx.beginPath()
                    ctx.moveTo(m, m + a); ctx.lineTo(m, m); ctx.lineTo(m + a, m)
                    ctx.stroke()
                    // top-right
                    ctx.beginPath()
                    ctx.moveTo(width - m - a, m); ctx.lineTo(width - m, m); ctx.lineTo(width - m, m + a)
                    ctx.stroke()
                    // bottom-left
                    ctx.beginPath()
                    ctx.moveTo(m, height - m - a); ctx.lineTo(m, height - m); ctx.lineTo(m + a, height - m)
                    ctx.stroke()
                    // bottom-right
                    ctx.beginPath()
                    ctx.moveTo(width - m - a, height - m); ctx.lineTo(width - m, height - m); ctx.lineTo(width - m, height - m - a)
                    ctx.stroke()
                }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -18
                    onClicked: page.chromeVisible = false
                }
            }
        }
    }

    Item {
        id: stage
        anchors.top: topBar.bottom
        anchors.bottom: bottomBar.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: page.chromeVisible ? page.chromeMargin : 0
        anchors.rightMargin: page.chromeVisible ? page.chromeMargin : 0
        anchors.topMargin: page.chromeVisible ? 8 : 0
        anchors.bottomMargin: page.chromeVisible ? 12 : 0

        RowLayout {
            id: spread
            anchors.fill: parent
            spacing: page.landscapeSpread ? 12 : 0
            visible: page.pageUrls.length > 0
            // Mirror in landscape so the current page (Repeater item 0) lands
            // on the right, matching manga RTL reading order.
            LayoutMirroring.enabled: page.landscapeSpread

            Repeater {
                model: page.visiblePageIndexes()
                delegate: Item {
                    id: pagePane
                    property int pageIndex: modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        anchors.fill: parent
                        color: "white"
                        border.color: Theme.ink
                        border.width: page.chromeVisible ? 1 : 0
                    }

                    Image {
                        anchors.fill: parent
                        anchors.margins: page.chromeVisible ? 1 : 0
                        fillMode: Image.PreserveAspectFit
                        cache: true
                        asynchronous: true
                        source: page.displaySource(page.pageUrls[pageIndex], page.imageGeneration)
                        onStatusChanged: {
                            if (status === Image.Ready) {
                                page.recordAspect(pageIndex,
                                                  sourceSize.width,
                                                  sourceSize.height)
                                // Don't clear ghostCleanPending here, the mode
                                // file is still "Content" until the timer (or
                                // an early tap) actually restores it. Clearing
                                // the flag too early would let the user's next
                                // tap skip the early-restore and ride GC16 =
                                // delay.
                                if (page.ghostCleanPending)
                                    ghostRestoreTimer.restart()
                            }
                        }
                    }

                }
            }
        }

        Text {
            visible: page.pageUrls.length === 0
            anchors.centerIn: parent
            text: "Loading…"
            font.family: Theme.serif
            font.italic: true
            font.pixelSize: 32
            color: Theme.inkMute
        }

        MouseArea {
            anchors.fill: parent
            property real pressX: 0
            property real pressY: 0
            property bool swiped: false

            onPressed: (mouse) => {
                pressX = mouse.x
                pressY = mouse.y
                swiped = false
            }
            onReleased: (mouse) => {
                const dx = mouse.x - pressX
                const dy = mouse.y - pressY
                const threshold = Math.max(60, width * 0.08)
                if (Math.abs(dx) >= threshold && Math.abs(dx) > Math.abs(dy) * 1.5) {
                    swiped = true
                    // Manga RTL: the current page slides to the right to reveal
                    // the next one. Swipe right -> next, swipe left -> previous.
                    if (dx > 0) page.advanceForward()
                    else        page.advanceBackward()
                }
            }
            onClicked: (mouse) => {
                if (swiped) return
                if (mouse.x < width / 2) page.advanceForward()
                else                     page.advanceBackward()
            }
        }

        Text {
            visible: page.chromeVisible
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.bottomMargin: 6
            anchors.leftMargin: 10
            text: "p." + page.pageRangeLabel()
            font.family: Theme.mono
            font.pixelSize: page.chromeTextSize
            color: Theme.inkMute
        }
    }

    Item {
        id: bottomBar
        visible: page.chromeVisible
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: page.chromeVisible ? page.bottomBarHeight : 0

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            color: Theme.ink
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: page.chromeMargin
            anchors.rightMargin: page.chromeMargin
            anchors.topMargin: 20
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "CH. · PAGE " + page.pageRangeLabel() + " / " + page.pageUrls.length
                    font.family: Theme.mono
                    font.pixelSize: page.chromeTextSize
                    font.letterSpacing: 1.7
                    color: Theme.inkMute
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: page.landscapeSpread ? "← NEXT SPREAD · PREV SPREAD →" : "← NEXT · PREV →"
                    font.family: Theme.mono
                    font.pixelSize: page.chromeTextSize
                    font.letterSpacing: 1.7
                    color: Theme.inkMute
                }
            }

            Item {
                id: scrubber
                Layout.fillWidth: true
                Layout.preferredHeight: 44

                function pageForX(px) {
                    const n = page.pageUrls.length
                    if (n <= 0) return 0
                    const clamped = Math.max(0, Math.min(width, px))
                    const idx = Math.round((clamped / Math.max(1, width)) * (n - 1))
                    return Math.max(0, Math.min(n - 1, n - 1 - idx))
                }

                function xForPage(index) {
                    const n = page.pageUrls.length
                    if (n <= 1) return width - 12
                    const clamped = Math.max(0, Math.min(n - 1, index))
                    return width - (width / (n - 1)) * clamped - 12
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: 1
                    color: Theme.ink
                }

                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0
                    layoutDirection: Qt.RightToLeft

                    Repeater {
                        model: Math.max(1, page.pageUrls.length)
                        delegate: Item {
                            required property int index
                            width: (parent.width) / Math.max(1, page.pageUrls.length)
                            height: 28
                            Rectangle {
                                anchors.centerIn: parent
                                width: 2
                                height: (index % 5 === 0) ? 18 : 10
                                color: Theme.ink
                                opacity: index >= page.currentPage && index <= page.visibleLastPage() ? 1 : 0.35
                            }
                        }
                    }
                }

                Rectangle {
                    visible: page.pageUrls.length > 0
                    width: 24; height: 24
                    color: Theme.ink
                    border.color: Theme.paper
                    border.width: 3
                    anchors.verticalCenter: parent.verticalCenter
                    x: scrubber.xForPage(page.currentPage)
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: page.pageUrls.length > 0
                    preventStealing: true
                    onPressed: (m) => page.goToPage(scrubber.pageForX(m.x))
                    onPositionChanged: (m) => {
                        if (pressed) page.goToPage(scrubber.pageForX(m.x))
                    }
                }
            }
        }
    }

    // Print crop mark, discreet "reveal UI" affordance in fullscreen.
    // Two hairline strokes with a gap at the apex (no corner drawn): the
    // typographic convention for printer's registration / trim marks. Sits
    // ~22 px in from the page corner, paper-on-paper, ink hairline only.
    Item {
        id: cropMark
        z: 10
        visible: !page.chromeVisible
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 34
        anchors.rightMargin: 34
        width: 36; height: 36

        Canvas {
            anchors.fill: parent
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.strokeStyle = Theme.ink
                ctx.lineWidth = 2
                ctx.lineCap = "square"
                // Horizontal arm, stops short of the corner.
                ctx.beginPath()
                ctx.moveTo(0, 0); ctx.lineTo(width - 8, 0)
                ctx.stroke()
                // Vertical arm, starts below the corner. Gap at the apex
                // is the trim-mark signature.
                ctx.beginPath()
                ctx.moveTo(width - 0.5, 8); ctx.lineTo(width - 0.5, height)
                ctx.stroke()
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -34  // 104×104 tactile target for finger on e-ink
            onClicked: page.chromeVisible = true
        }
    }
    }
}
