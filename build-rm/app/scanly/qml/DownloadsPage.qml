import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import app.scanly

Page {
    id: page
    background: Rectangle { color: Theme.paper }

    property var completedList: downloads.completedDownloads()
    property var mangaList: downloads.downloadedMangas()

    function refreshCompleted() {
        page.completedList = downloads.completedDownloads()
        page.mangaList = downloads.downloadedMangas()
    }

    Connections {
        target: downloads
        function onChapterDownloadFinished(cid) { page.refreshCompleted() }
        function onChapterRemoved(cid)          { page.refreshCompleted() }
        function onManifestChanged()            { page.refreshCompleted() }
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
            visible: page.completedList.length > 0

            RowLayout {
                anchors.fill: parent
                spacing: 22

                Rectangle {
                    Layout.preferredWidth: 168
                    Layout.preferredHeight: 244
                    color: "transparent"
                    border.color: Theme.ink
                    border.width: 3

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 12
                        color: Theme.paper
                        border.color: Theme.hairline
                        border.width: 1
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 22
                        spacing: 8

                        Text {
                            text: "OFFLINE"
                            font.family: Theme.mono
                            font.pixelSize: 19
                            font.letterSpacing: 1.0
                            color: Theme.inkMute
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Item { Layout.fillHeight: true }
                        Text {
                            text: String(page.completedList.length)
                            font.family: Theme.serif
                            font.italic: true
                            font.weight: Font.DemiBold
                            font.pixelSize: 74
                            color: Theme.ink
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: page.completedList.length === 1 ? "CHAPTER" : "CHAPTERS"
                            font.family: Theme.mono
                            font.pixelSize: 18
                            font.letterSpacing: 1.0
                            color: Theme.inkMute
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Item { Layout.fillHeight: true }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 6
                    spacing: 4

                    Text {
                        text: "LOCAL STORAGE"
                        font.family: Theme.mono
                        font.pixelSize: 20
                        font.letterSpacing: 1.0
                        color: Theme.inkMute
                    }
                    Text {
                        text: "Downloads"
                        font.family: Theme.serif
                        font.italic: true
                        font.weight: Font.DemiBold
                        font.pixelSize: 66
                        font.letterSpacing: 0
                        color: Theme.ink
                        Layout.topMargin: 6
                    }
                    Text {
                        text: (downloads.totalSizeOnDisk() / (1024 * 1024)).toFixed(1)
                              + " MB disponibles hors ligne"
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
                            Layout.preferredWidth: 240
                            Layout.preferredHeight: 60
                            Rectangle {
                                anchors.fill: parent
                                color: Theme.ink
                                Text {
                                    anchors.centerIn: parent
                                    text: "READ OFFLINE"
                                    font.family: Theme.mono
                                    font.pixelSize: 22
                                    font.letterSpacing: 1.0
                                    color: Theme.paper
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                enabled: page.completedList.length > 0
                                onClicked: {
                                    const first = page.completedList[0]
                                    if (first && first.mangaId && first.mangaId !== "")
                                        app.openReader(first.mangaId, first.mangaTitle,
                                                       first.chapterId, 0)
                                }
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
                text: "Offline library"
                font.family: Theme.serif
                font.italic: true
                font.weight: Font.DemiBold
                font.pixelSize: 44
                color: Theme.ink
            }
            Text {
                text: page.mangaList.length + " series · " + page.completedList.length + " chapters"
                font.family: Theme.mono
                font.pixelSize: 20
                font.letterSpacing: 1.0
                color: Theme.inkMute
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "LOCAL"
                font.family: Theme.mono
                font.pixelSize: 20
                font.letterSpacing: 1.0
                color: Theme.inkSoft
            }
            Text {
                text: "RECENT"
                font.family: Theme.mono
                font.pixelSize: 20
                font.letterSpacing: 1.0
                color: Theme.inkMute
            }
        }

        Item {
            visible: page.mangaList.length === 0
            Layout.fillWidth: true
            Layout.preferredHeight: 300

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 14
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No offline chapters"
                    font.family: Theme.serif
                    font.italic: true
                    font.pixelSize: 52
                    color: Theme.inkSoft
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "DOWNLOAD CHAPTERS FROM A SERIES PAGE"
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
            model: page.mangaList
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

                Item {
                    id: inner
                    anchors.fill: parent
                    anchors.margins: shelf.gap / 2

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        MangaCover {
                            Layout.fillWidth: true
                            Layout.preferredHeight: width * 1.45
                            title: card.modelData.mangaTitle || "(unknown)"
                            imageSource: card.modelData.coverPath
                                ? "file://" + card.modelData.coverPath
                                : ""
                            showLabel: false
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: card.modelData.mangaTitle || "(unknown)"
                                font.family: Theme.serif
                                font.italic: true
                                font.weight: Font.DemiBold
                                font.pixelSize: 24
                                color: Theme.ink
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                maximumLineCount: 1
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text {
                                    text: card.modelData.chapterCount
                                          + (card.modelData.chapterCount === 1 ? " chapter" : " chapters")
                                    font.family: Theme.mono
                                    font.pixelSize: 16
                                    font.letterSpacing: 0.8
                                    color: Theme.inkMute
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: (card.modelData.sizeBytes / (1024 * 1024)).toFixed(1) + " MB"
                                    font.family: Theme.mono
                                    font.pixelSize: 16
                                    color: Theme.inkMute
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (card.modelData.mangaId && card.modelData.mangaId !== "")
                                app.openOfflineManga(card.modelData.mangaId,
                                                     card.modelData.mangaTitle)
                        }
                    }
                }
            }
        }
    }

    Hairline { anchors.bottom: footerRow.top; anchors.left: parent.left; anchors.right: parent.right }
    RowLayout {
        id: footerRow
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 48
        anchors.rightMargin: 48
        height: 44

        Text {
            text: "TAP A SERIES TO SEE OFFLINE CHAPTERS"
            font.family: Theme.mono
            font.pixelSize: 18
            font.letterSpacing: 1.0
            color: Theme.inkMute
        }
        Item { Layout.fillWidth: true }
        Text {
            text: "PRE-SCALED · 1620 PX · JPEG q88"
            font.family: Theme.mono
            font.pixelSize: 18
            font.letterSpacing: 1.0
            color: Theme.inkMute
        }
    }
}
