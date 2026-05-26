import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import app.scanly

Page {
    id: page
    signal mangaSelected(string id, string title, string coverUrl)

    background: Rectangle { color: Theme.paper }

    property string lastError: ""

    Connections {
        target: mangaDex
        function onErrorOccurred(msg) { page.lastError = msg }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.margin
        anchors.rightMargin: Theme.margin
        anchors.topMargin: 36
        anchors.bottomMargin: 24
        spacing: 28

        RowLayout {
            Layout.fillWidth: true
            spacing: 18

            Text {
                text: "I."
                font.family: Theme.display
                font.italic: true
                font.pixelSize: 44
                color: Theme.seal
            }
            Text {
                text: "Recherche"
                font.family: Theme.display
                font.italic: true
                font.pixelSize: 56
                color: Theme.ink
            }
            Item { Layout.fillWidth: true }
            Text {
                text: results.count + " résultats"
                font.family: Theme.mono
                font.pixelSize: 13
                font.letterSpacing: 2
                color: Theme.mute
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 12
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.hairline }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                text: "↳"
                font.pixelSize: 36
                font.family: Theme.display
                color: Theme.seal
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 16
            }

            TextField {
                id: search
                Layout.fillWidth: true
                placeholderText: "Tapez un titre — Berserk, Vinland Saga, Vagabond…"
                font.family: Theme.display
                font.italic: true
                font.pixelSize: 34
                color: Theme.ink
                placeholderTextColor: Theme.mute
                background: Item {
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: Theme.ink
                    }
                }
                onAccepted: page.doSearch()
            }

            Item {
                width: 200
                height: 70
                Layout.leftMargin: 18

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: Theme.ink
                    border.width: 1
                }
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    color: "transparent"
                    border.color: Theme.ink
                    border.width: 1
                }
                Text {
                    anchors.centerIn: parent
                    text: "CHERCHER  →"
                    font.family: Theme.caps
                    font.pixelSize: 18
                    font.letterSpacing: 4
                    color: Theme.ink
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: page.doSearch()
                }
            }
        }

        Rectangle {
            visible: page.lastError !== ""
            Layout.fillWidth: true
            color: "transparent"
            border.color: Theme.seal
            border.width: 1
            height: errLine.implicitHeight + 24

            Text {
                id: errLine
                anchors.fill: parent
                anchors.margins: 12
                text: "✕  " + page.lastError
                font.family: Theme.mono
                font.pixelSize: 14
                color: Theme.seal
                wrapMode: Text.WordWrap
            }
        }

        Item {
            visible: results.count === 0 && page.lastError === ""
            Layout.fillWidth: true
            Layout.preferredHeight: 240

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 14

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "—"
                    font.pixelSize: 28
                    color: Theme.mute
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Le catalogue est vide."
                    font.family: Theme.display
                    font.italic: true
                    font.pixelSize: 28
                    color: Theme.subtle
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "TAPEZ UN TITRE PUIS PRESSEZ ENTRÉE"
                    font.family: Theme.caps
                    font.pixelSize: 13
                    font.letterSpacing: 4
                    color: Theme.mute
                }
            }
        }

        ListView {
            id: results
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: searchModel
            spacing: 0
            clip: true
            cacheBuffer: 2400
            interactive: true

            delegate: Item {
                id: row
                required property string mangaId
                required property string title
                required property string coverUrl
                required property string description

                width: ListView.view.width
                height: 280

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Theme.hairline
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.topMargin: 28
                    anchors.bottomMargin: 28
                    spacing: 28

                    Item {
                        Layout.preferredWidth: 168
                        Layout.preferredHeight: 224

                        Rectangle {
                            anchors.fill: parent
                            color: Theme.highlight
                            border.color: Theme.ink
                            border.width: 1
                        }
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            color: "transparent"
                            border.color: Theme.ink
                            border.width: 1
                        }
                        Image {
                            anchors.fill: parent
                            anchors.margins: 8
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            source: row.coverUrl
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 10

                        Text {
                            text: row.title
                            font.family: Theme.display
                            font.italic: true
                            font.pixelSize: 36
                            color: Theme.ink
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                        Text {
                            text: "MANGA  ·  TRADUCTION FR / EN  ·  SOURCE MANGADEX"
                            font.family: Theme.mono
                            font.pixelSize: 12
                            font.letterSpacing: 2.5
                            color: Theme.mute
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: row.description.length > 0
                                ? row.description
                                : "Aucun synopsis disponible pour cette édition."
                            font.family: Theme.body
                            font.pixelSize: 18
                            color: Theme.subtle
                            wrapMode: Text.WordWrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                            lineHeight: 1.25
                        }
                        RowLayout {
                            spacing: 12
                            Text {
                                text: "LIRE"
                                font.family: Theme.caps
                                font.pixelSize: 13
                                font.letterSpacing: 3
                                color: Theme.seal
                            }
                            Text {
                                text: "→"
                                font.pixelSize: 18
                                color: Theme.seal
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: page.mangaSelected(row.mangaId, row.title, row.coverUrl)
                }
            }
        }
    }

    function doSearch() {
        page.lastError = ""
        console.log("[SearchPage] searching:", search.text)
        mangaDex.searchManga(search.text)
    }
}
