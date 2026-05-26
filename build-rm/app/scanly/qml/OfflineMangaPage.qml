import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import app.scanly

Page {
    id: page
    property string mangaId
    property string mangaTitle
    property var chapterList: []

    background: Rectangle { color: Theme.paper }

    function refresh() {
        page.chapterList = downloads.downloadedChaptersFor(page.mangaId)
    }
    Component.onCompleted: refresh()

    Connections {
        target: downloads
        function onChapterRemoved(cid)   { page.refresh() }
        function onManifestChanged()     { page.refresh() }
    }

    function labelFor(ch) {
        const isBook = ch.pageCount > 80
        const prefix = isBook ? "Book " : "Chapter "
        return ch.chapterNumber && ch.chapterNumber !== ""
            ? prefix + ch.chapterNumber
            : (isBook ? "Book" : "Chapter")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 48
        anchors.rightMargin: 48
        anchors.topMargin: 28
        anchors.bottomMargin: 24
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            spacing: 28

            MangaCover {
                Layout.preferredWidth: 220
                Layout.preferredHeight: 322
                title: page.mangaTitle
                imageSource: downloads.coverPathFor(page.mangaId)
                              ? "file://" + downloads.coverPathFor(page.mangaId)
                              : ""
                accent: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 4

                Text {
                    text: "OFFLINE · " + page.chapterList.length + " CHAPTERS"
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
                    font.pixelSize: 76
                    color: Theme.ink
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    lineHeight: 0.95
                }
                Text {
                    text: "Stored locally · ready to read."
                    font.family: Theme.serif
                    font.italic: true
                    font.pixelSize: 28
                    color: Theme.inkSoft
                    Layout.topMargin: 6
                }
            }
        }

        Hairline { Layout.fillWidth: true; Layout.topMargin: 22 }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 16
            Layout.bottomMargin: 10
            Text {
                text: "Downloaded chapters"
                font.family: Theme.serif
                font.italic: true
                font.weight: Font.DemiBold
                font.pixelSize: 40
                color: Theme.ink
            }
            Item { Layout.fillWidth: true }
            Text {
                text: page.chapterList.length + " items"
                font.family: Theme.mono
                font.pixelSize: 20
                font.letterSpacing: 1.0
                color: Theme.inkMute
            }
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: page.chapterList
            clip: true
            spacing: 0

            delegate: Item {
                id: row
                required property var modelData
                required property int index
                width: ListView.view.width
                height: 96

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 2
                    color: Theme.ink
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 22

                    Text {
                        Layout.preferredWidth: 200
                        text: page.labelFor(row.modelData)
                        font.family: Theme.serif
                        font.italic: true
                        font.weight: Font.DemiBold
                        font.pixelSize: 34
                        color: Theme.ink
                        elide: Text.ElideRight
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: row.modelData.chapterTitle && row.modelData.chapterTitle !== ""
                                ? row.modelData.chapterTitle
                                : "—"
                            font.family: Theme.serif
                            font.italic: row.modelData.chapterTitle === ""
                            font.pixelSize: 28
                            color: Theme.ink
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: row.modelData.pageCount + " pages · "
                                  + (row.modelData.sizeBytes / (1024 * 1024)).toFixed(1) + " MB"
                            font.family: Theme.mono
                            font.pixelSize: 18
                            font.letterSpacing: 0.8
                            color: Theme.inkMute
                        }
                    }
                    Item {
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 56
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: Theme.ink
                            border.width: 2
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "REMOVE"
                            font.family: Theme.mono
                            font.pixelSize: 18
                            font.letterSpacing: 1.0
                            color: Theme.ink
                        }
                        MouseArea {
                            anchors.fill: parent
                            z: 2
                            onClicked: downloads.removeChapter(row.modelData.chapterId)
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: -1
                    onClicked: app.openReader(row.modelData.mangaId,
                                              row.modelData.mangaTitle,
                                              row.modelData.chapterId,
                                              0)
                }
            }
        }
    }
}
