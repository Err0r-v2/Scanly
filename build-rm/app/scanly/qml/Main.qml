import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import app.scanly

ApplicationWindow {
    id: app
    visible: true
    width: 1620
    height: 2160
    title: "Scanly"
    color: Theme.paper

    property string section: "library"
    property string crumb: ""
    property int libraryCount: 0
    property int activeDownloads: 0
    property bool readerOpen: false

    function refreshCounters() {
        libraryCount = libraryStore.rowCount()
        activeDownloads = downloads.activeDownloads().length
    }
    Component.onCompleted: refreshCounters()

    Connections {
        target: libraryStore
        function onRowsInserted() { app.refreshCounters() }
        function onRowsRemoved()  { app.refreshCounters() }
        function onModelReset()   { app.refreshCounters() }
    }
    Connections {
        target: downloads
        function onManifestChanged()          { app.refreshCounters() }
        function onChapterDownloadStarted()   { app.refreshCounters() }
        function onChapterDownloadFinished()  { app.refreshCounters() }
        function onChapterDownloadFailed()    { app.refreshCounters() }
    }

    StatusBar {
        id: status
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        visible: !app.readerOpen
        height: app.readerOpen ? 0 : implicitHeight
        section: "Scanly"
        crumb: app.crumb
    }

    RowLayout {
        anchors.top: status.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 0

        Sidebar {
            id: sidebar
            Layout.fillHeight: true
            visible: !app.readerOpen
            Layout.preferredWidth: app.readerOpen ? 0 : 310
            current: app.section
            librarySize: app.libraryCount
            downloadsActive: app.activeDownloads
            onNavigate: (key) => app.go(key)
            onQuitRequested: Qt.quit()
        }

        StackView {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true

            pushEnter:    Transition {}
            pushExit:     Transition {}
            popEnter:     Transition {}
            popExit:      Transition {}
            replaceEnter: Transition {}
            replaceExit:  Transition {}

            initialItem: libraryComponent
        }
    }

    Component { id: libraryComponent;   LibraryPage   { onOpenManga: (id, t, c) => app.openManga(id, t, c) } }
    Component { id: discoverComponent;  DiscoverPage  { onOpenManga: (id, t, c) => app.openManga(id, t, c) } }
    Component { id: settingsComponent;  SettingsPage  {} }
    Component { id: mangaComponent;     MangaPage     {} }
    Component { id: readerComponent;    ReaderPage    {} }

    function go(key) {
        section = key
        crumb = ""
        if (key === "library")        stack.replace(null, libraryComponent)
        else if (key === "discover")  stack.replace(null, discoverComponent)
        else if (key === "settings")  stack.replace(null, settingsComponent)
    }
    function openManga(id, title, coverUrl) {
        crumb = title
        stack.push(mangaComponent, { mangaId: id, mangaTitle: title, coverUrl: coverUrl || "" })
    }
    function openReader(mid, mt, cid, idx) {
        crumb = mt
        readerOpen = true
        stack.push(readerComponent, {
            mangaId: mid, mangaTitle: mt, chapterId: cid, startPage: idx || 0
        })
    }

}
