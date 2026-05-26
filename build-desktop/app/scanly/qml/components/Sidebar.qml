import QtQuick
import QtQuick.Layouts
import app.scanly

Item {
    id: root
    property string current: "library"
    property int librarySize: 0
    property int downloadsActive: 0
    signal navigate(string key)
    signal quitRequested()

    width: 310

    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 2
        color: Theme.ink
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 44
        anchors.rightMargin: 28
        anchors.topMargin: 36
        anchors.bottomMargin: 32
        spacing: 0

        Wordmark { size: 50 }

        Item { Layout.preferredHeight: 44 }

        Repeater {
            model: [
                { key: "library",   label: "Library",   count: root.librarySize },
                { key: "discover",  label: "Discover",  count: -1 },
                { key: "settings",  label: "Settings",  count: -1 },
            ]
            delegate: Item {
                Layout.fillWidth: true
                implicitHeight: 72
                property bool active: root.current === modelData.key

                Rectangle {
                    visible: parent.active
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: -40
                    width: 7; height: 34
                    color: Theme.ink
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                        text: modelData.label
                        font.family: Theme.serif
                        font.pixelSize: 43
                        font.weight: parent.parent.active ? Font.DemiBold : Font.Normal
                        color: parent.parent.active ? Theme.ink : Theme.inkSoft
                        Layout.fillWidth: true
                    }
                    Text {
                        visible: modelData.count > 0
                        text: modelData.count
                        font.family: Theme.mono
                        font.pixelSize: 24
                        color: modelData.key === "downloads" && modelData.count > 0
                               ? Theme.accent : Theme.inkMute
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.navigate(modelData.key)
                }
            }
        }

        Item { Layout.fillHeight: true }

        Item {
            Layout.fillWidth: true
            implicitHeight: 58

            Rectangle {
                anchors.fill: parent
                color: quitArea.pressed ? Theme.ink : "transparent"
                border.width: 2
                border.color: Theme.ink
            }

            Text {
                anchors.centerIn: parent
                text: "QUIT"
                font.family: Theme.mono
                font.pixelSize: 23
                font.letterSpacing: 1.8
                color: quitArea.pressed ? Theme.paper : Theme.ink
            }

            MouseArea {
                id: quitArea
                anchors.fill: parent
                onClicked: root.quitRequested()
            }
        }

        Item { Layout.preferredHeight: 24 }

        Hairline { Layout.fillWidth: true; strength: 1.0 }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 18
            spacing: 6

            Text {
                text: "STORAGE"
                font.family: Theme.mono
                font.pixelSize: 20
                font.letterSpacing: 1.8
                color: Theme.inkMute
            }
            Text {
                text: (device.storageBytesUsed / (1024 * 1024 * 1024)).toFixed(1)
                      + " / "
                      + (device.storageBytesTotal / (1024 * 1024 * 1024)).toFixed(1)
                      + " GB"
                font.family: Theme.mono
                font.pixelSize: 25
                color: Theme.inkSoft
            }
            Rectangle {
                Layout.fillWidth: true
                height: 6
                color: Theme.paperEdge
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: Math.min(parent.width,
                        device.storageBytesTotal > 0
                            ? parent.width * device.storageBytesUsed / device.storageBytesTotal
                            : 0)
                    color: Theme.ink
                }
            }
        }
    }
}
