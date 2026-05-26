import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import app.scanly

Page {
    id: page
    signal openManga(string id, string title, string coverUrl)

    background: Rectangle { color: Theme.paper }

    property var continueEntry: libraryStore.firstEntry()
    property bool hasEntry: continueEntry && continueEntry.mangaId !== undefined && continueEntry.mangaId !== ""

    property string sortMode: "recent" // "recent" | "az"
    property var sortedEntries: rebuildSorted()

    function refreshContinue() { page.continueEntry = libraryStore.firstEntry() }
    function rebuildSorted() {
        const out = []
        for (var i = 0; i < libraryStore.rowCount(); i++)
            out.push(libraryStore.entryAt(i))
        if (page.sortMode === "az") {
            out.sort(function(a, b) {
                return (a.title || "").toLowerCase()
                    .localeCompare((b.title || "").toLowerCase())
            })
        } else {
            // most recent first, newest entries are appended to the end of
            // the underlying list, so reverse for display.
            out.reverse()
        }
        return out
    }
    function refresh() {
        refreshContinue()
        page.sortedEntries = rebuildSorted()
    }
    onSortModeChanged: page.sortedEntries = rebuildSorted()

    Connections {
        target: libraryStore
        function onRowsInserted() { page.refresh() }
        function onRowsRemoved()  { page.refresh() }
        function onDataChanged()  { page.refresh() }
        function onModelReset()   { page.refresh() }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 48
        anchors.rightMargin: 48
        anchors.topMargin: 28
        anchors.bottomMargin: 0
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 270
            visible: page.hasEntry

            RowLayout {
                anchors.fill: parent
                spacing: 22

                MangaCover {
                    Layout.preferredWidth: 168
                    Layout.preferredHeight: 244
                    title: page.hasEntry ? page.continueEntry.title : ""
                    imageSource: page.hasEntry ? page.continueEntry.coverUrl : ""
                    showLabel: false
                    MouseArea {
                        anchors.fill: parent
                        enabled: page.hasEntry
                        onClicked: page.openManga(page.continueEntry.mangaId,
                                                  page.continueEntry.title,
                                                  page.continueEntry.coverUrl)
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 6
                    spacing: 4

                    Text {
                        text: "CONTINUE READING"
                        font.family: Theme.mono
                        font.pixelSize: 20
                        font.letterSpacing: 1.0
                        color: Theme.inkMute
                    }
                    Text {
                        text: page.hasEntry ? page.continueEntry.title : ""
                        font.family: Theme.serif
                        font.pixelSize: 66
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0
                        color: Theme.ink
                        Layout.topMargin: 6
                    }
                    Text {
                        text: page.hasEntry && page.continueEntry.lastChapterId !== ""
                            ? "Resume at page " + (page.continueEntry.lastPageIndex + 1)
                            : "No chapter in progress · open series"
                        font.family: Theme.serif
                        font.italic: true
                        font.pixelSize: 34
                        color: Theme.inkSoft
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        spacing: 8
                        Layout.topMargin: 12

                        Item {
                            Layout.preferredWidth: 210
                            Layout.preferredHeight: 60
                            Rectangle {
                                anchors.fill: parent
                                color: Theme.ink
                                Text {
                                    anchors.centerIn: parent
                                    text: "RESUME →"
                                    font.family: Theme.mono
                                    font.pixelSize: 22
                                    font.letterSpacing: 1.0
                                    color: Theme.paper
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                enabled: page.hasEntry
                                onClicked: {
                                    if (page.continueEntry.lastChapterId !== "")
                                        app.openReader(page.continueEntry.mangaId,
                                                       page.continueEntry.title,
                                                       page.continueEntry.lastChapterId,
                                                       page.continueEntry.lastPageIndex)
                                    else
                                        page.openManga(page.continueEntry.mangaId,
                                                       page.continueEntry.title,
                                                       page.continueEntry.coverUrl)
                                }
                            }
                        }
                        Item {
                            Layout.preferredWidth: 190
                            Layout.preferredHeight: 60
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: Theme.ink
                                border.width: 2
                                Text {
                                    anchors.centerIn: parent
                                    text: "CHAPTERS"
                                    font.family: Theme.mono
                                    font.pixelSize: 22
                                    font.letterSpacing: 1.0
                                    color: Theme.ink
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                enabled: page.hasEntry
                                onClicked: page.openManga(
                                    page.continueEntry.mangaId,
                                    page.continueEntry.title,
                                    page.continueEntry.coverUrl)
                            }
                        }
                    }
                }
            }
        }

        Hairline { Layout.fillWidth: true; Layout.topMargin: 20 }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 16
            Layout.bottomMargin: 14
            spacing: 18

            Text {
                text: "Library"
                font.family: Theme.serif
                font.italic: true
                font.weight: Font.DemiBold
                font.pixelSize: 44
                color: Theme.ink
            }
            Text {
                text: libraryStore.rowCount() + " series"
                font.family: Theme.mono
                font.pixelSize: 20
                font.letterSpacing: 1.0
                color: Theme.inkMute
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "RECENT"
                font.family: Theme.mono
                font.pixelSize: 20
                font.letterSpacing: 1.0
                color: page.sortMode === "recent" ? Theme.ink : Theme.inkMute
                font.weight: page.sortMode === "recent" ? Font.DemiBold : Font.Normal
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -10
                    onClicked: {
                        page.sortMode = "recent"
                        epaper.partialRefresh()
                    }
                }
            }
            Text {
                text: "A–Z"
                font.family: Theme.mono
                font.pixelSize: 20
                font.letterSpacing: 1.0
                color: page.sortMode === "az" ? Theme.ink : Theme.inkMute
                font.weight: page.sortMode === "az" ? Font.DemiBold : Font.Normal
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -10
                    onClicked: {
                        page.sortMode = "az"
                        epaper.partialRefresh()
                    }
                }
            }
        }

        Item {
            visible: libraryStore.rowCount() === 0
            Layout.fillWidth: true
            Layout.preferredHeight: 300

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 14
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Library is empty"
                    font.family: Theme.serif
                    font.italic: true
                    font.pixelSize: 52
                    color: Theme.inkSoft
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "ADD SERIES FROM DISCOVER"
                    font.family: Theme.mono
                    font.pixelSize: 22
                    font.letterSpacing: 1.2
                    color: Theme.inkMute
                }
            }
        }

        GridView {
            id: shelf
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: page.sortedEntries
            readonly property int cols: 4
            readonly property int gap: 22
            cellWidth: shelf.width / cols
            cellHeight: Math.round((cellWidth - gap) * 1.55) + gap
            clip: true
            interactive: true

            delegate: Item {
                id: card
                required property var modelData

                width: shelf.cellWidth
                height: shelf.cellHeight

                MangaCover {
                    anchors.fill: parent
                    anchors.margins: shelf.gap / 2
                    title: card.modelData.title
                    imageSource: card.modelData.coverUrl
                    dense: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: page.openManga(card.modelData.mangaId,
                                              card.modelData.title,
                                              card.modelData.coverUrl)
                }
            }
        }
    }

}
