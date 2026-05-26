import QtQuick
import app.scanly

Item {
    id: root
    property string title: ""
    property string vol: ""
    property string imageSource: ""
    property bool dense: false
    property bool showLabel: true
    readonly property real nativeAspect: (img.status === Image.Ready
                                          && img.implicitWidth > 0)
        ? img.implicitHeight / img.implicitWidth
        : 1.466

    Rectangle {
        id: frame
        anchors.fill: parent
        color: Theme.paperDeep
        border.color: Theme.ink
        border.width: 2

        Item {
            id: inner
            anchors.fill: parent
            anchors.margins: frame.border.width
            anchors.bottomMargin: labelStrip.visible
                ? labelStrip.height + frame.border.width : frame.border.width
            clip: true

            Canvas {
                id: halftone
                anchors.fill: parent
                opacity: 0.35
                visible: root.imageSource === ""
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.fillStyle = Theme.ink;
                    for (let y = 2; y < height; y += 4) {
                        for (let x = 2; x < width; x += 4) {
                            ctx.beginPath();
                            ctx.arc(x, y, 0.6, 0, Math.PI * 2);
                            ctx.fill();
                        }
                    }
                }
            }

            Text {
                visible: root.imageSource === ""
                anchors.fill: parent
                anchors.margins: 8
                text: root.title.split(" ")[0]
                font.family: Theme.serif
                font.italic: true
                font.weight: Font.DemiBold
                font.pixelSize: root.dense
                    ? Math.max(12, root.height * 0.22)
                    : Math.max(14, root.height * 0.30)
                font.letterSpacing: 0
                color: Theme.ink
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                lineHeight: 0.85
            }

            Image {
                id: img
                visible: root.imageSource !== ""
                anchors.fill: parent
                source: root.imageSource
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: true
            }
        }

        Rectangle {
            id: labelStrip
            visible: root.showLabel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: frame.border.width
            anchors.rightMargin: frame.border.width
            anchors.bottomMargin: frame.border.width
            height: labelCol.implicitHeight + 16
            color: Theme.paper

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                color: Theme.ink
            }

            Column {
                id: labelCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 2

                Text {
                    width: parent.width
                    text: root.title
                    font.family: Theme.serif
                    font.pixelSize: root.dense ? 18 : 20
                    font.weight: Font.DemiBold
                    color: Theme.ink
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
                Text {
                    visible: root.vol !== ""
                    text: "VOL. " + root.vol
                    font.family: Theme.mono
                    font.pixelSize: root.dense ? 16 : 18
                    font.letterSpacing: 0.5
                    color: Theme.inkMute
                }
            }
        }
    }
}
