import QtQuick
import app.scanly

Row {
    spacing: 0
    property int size: 32

    Text {
        text: "Scanly"
        font.family: Theme.serif
        font.pixelSize: size
        font.italic: true
        font.weight: Font.Medium
        font.letterSpacing: 0
        color: Theme.ink
    }
    Text {
        text: "."
        font.family: Theme.serif
        font.pixelSize: size * 0.55
        font.italic: true
        color: Theme.inkMute
        leftPadding: 4
        anchors.baseline: parent.children[0].baseline
    }
}
