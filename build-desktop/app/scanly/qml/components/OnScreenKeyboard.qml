import QtQuick
import QtQuick.Layouts
import app.scanly

// Visually faithful clone of the xochitl on-screen keyboard:
// black panel, borderless white letters, outlined space bar, filled
// white return key, top toolbar with undo/redo + Close.
Item {
    id: keyboard

    property Item target
    property bool symbols: false
    property bool shifted: false
    readonly property bool azerty: settings.keyboardLayout === "azerty"
    signal accepted()
    signal dismissed()

    implicitHeight: 540

    // shared cell pitch, every letter row uses the same so columns
    // line up between rows.
    readonly property real cellWidth: Math.max(40, (width - 120) / 10)

    // ---------- input plumbing ----------

    function keyLabel(value) {
        return keyboard.shifted && !keyboard.symbols ? value.toUpperCase() : value
    }

    function insertText(value) {
        if (!target) return
        target.insert(target.cursorPosition, keyboard.keyLabel(value))
        if (keyboard.shifted && !keyboard.symbols)
            keyboard.shifted = false
        target.forceActiveFocus()
        epaper.partialRefresh()
    }

    function backspace() {
        if (!target) return
        if (target.selectedText.length > 0)
            target.remove(target.selectionStart, target.selectionEnd)
        else if (target.cursorPosition > 0)
            target.remove(target.cursorPosition - 1, target.cursorPosition)
        target.forceActiveFocus()
        epaper.partialRefresh()
    }

    function undo() { if (target && target.canUndo) target.undo() }
    function redo() { if (target && target.canRedo) target.redo() }

    function toggleSymbols() {
        keyboard.symbols = !keyboard.symbols
        keyboard.shifted = false
        if (target) target.forceActiveFocus()
        epaper.partialRefresh()
    }

    function toggleShift() {
        keyboard.shifted = !keyboard.shifted
        if (target) target.forceActiveFocus()
        epaper.partialRefresh()
    }

    // ---------- visual ----------

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 60
        anchors.rightMargin: 60
        anchors.topMargin: 18
        anchors.bottomMargin: 22
        spacing: 0

        // top bar: undo / redo / Close
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 56

            IconButton {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 64; height: 56
                kind: "undo"
                onPressed: keyboard.undo()
            }
            IconButton {
                anchors.left: parent.left
                anchors.leftMargin: 90
                anchors.verticalCenter: parent.verticalCenter
                width: 64; height: 56
                kind: "redo"
                onPressed: keyboard.redo()
            }
            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "Close"
                font.family: Theme.serif
                font.pixelSize: 26
                color: "#ffffff"
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -16
                    onClicked: keyboard.dismissed()
                }
            }
        }

        // Row 1, qwertyuiop (10 letters)
        LetterRow {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            Layout.topMargin: 6
            keys: keyboard.symbols
                ? ["1","2","3","4","5","6","7","8","9","0"]
                : (keyboard.azerty
                    ? ["a","z","e","r","t","y","u","i","o","p"]
                    : ["q","w","e","r","t","y","u","i","o","p"])
        }

        // Row 2, asdfghjkl, centered, same cell pitch as row 1
        LetterRow {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            keys: keyboard.symbols
                ? ["@","#","$","&","*","(",")","'","\""]
                : (keyboard.azerty
                    ? ["q","s","d","f","g","h","j","k","l","m"]
                    : ["a","s","d","f","g","h","j","k","l"])
        }

        // Row 3, zxcvbnm centered + backspace aligned with enter pill below.
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 80

            LetterRow {
                anchors.fill: parent
                keys: keyboard.symbols
                    ? ["-","/",":",";","?","!","'"]
                    : (keyboard.azerty
                        ? ["w","x","c","v","b","n"]
                        : ["z","x","c","v","b","n","m"])
            }

            // Decalé pour tomber pile entre globe et 123 de la bottom row :
            // bottom row layout = globe(60) + spacer(48) + 123(60).
            // Centre entre globe (x=30) et 123 (x=138) = x=84.
            // Shift width 64 → leftMargin = 84 − 32 = 52.
            IconButton {
                anchors.left: parent.left
                anchors.leftMargin: 52
                anchors.verticalCenter: parent.verticalCenter
                width: 64; height: 56
                kind: "shift"
                active: keyboard.shifted
                onPressed: keyboard.toggleShift()
            }

            // Backspace center aligned with the enter pill center
            // (enter pill is 180 wide, anchored right → its center is at
            // parent.right - 90). Backspace width 72 → rightMargin = 54.
            IconButton {
                anchors.right: parent.right
                anchors.rightMargin: 54
                anchors.verticalCenter: parent.verticalCenter
                width: 72; height: 56
                kind: "backspace"
                onPressed: keyboard.backspace()
            }
        }

        // Bottom row, globe, 123, comma, [space outline], period, [enter filled]
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 96
            Layout.topMargin: 14
            spacing: 0

            IconButton {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 60
                Layout.alignment: Qt.AlignVCenter
                kind: "globe"
                onPressed: settings.toggleKeyboardLayout()
            }

            Item { Layout.preferredWidth: 48; Layout.preferredHeight: 1 }

            CharKey {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 60
                Layout.alignment: Qt.AlignVCenter
                label: keyboard.symbols ? "abc" : "123"
                onPressed: keyboard.toggleSymbols()
            }

            Item { Layout.fillWidth: true }

            CharKey {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 60
                Layout.alignment: Qt.AlignVCenter
                label: ","
                onPressed: keyboard.insertText(",")
            }

            // outlined space bar
            Item {
                id: spaceBtn
                Layout.preferredWidth: 560
                Layout.preferredHeight: 84
                Layout.leftMargin: 36
                Layout.rightMargin: 36
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: "#ffffff"
                    border.width: 2
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: keyboard.insertText(" ")
                }
            }

            CharKey {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 60
                Layout.alignment: Qt.AlignVCenter
                label: "."
                onPressed: keyboard.insertText(".")
            }

            Item { Layout.fillWidth: true }

            // filled enter pill
            Item {
                Layout.preferredWidth: 180
                Layout.preferredHeight: 84
                Layout.alignment: Qt.AlignVCenter
                Rectangle {
                    anchors.fill: parent
                    color: "#ffffff"
                }
                IconGlyph {
                    anchors.centerIn: parent
                    kind: "enter"
                    color: "#000000"
                    size: 30
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: keyboard.accepted()
                }
            }
        }
    }

    // ---------- components ----------

    component LetterRow: Item {
        id: row
        property var keys: []
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height
            spacing: 0
            Repeater {
                model: row.keys
                delegate: LetterKey {
                    required property string modelData
                    width: keyboard.cellWidth
                    height: row.height
                    label: keyboard.keyLabel(modelData)
                    onPressed: keyboard.insertText(modelData)
                }
            }
        }
    }

    component LetterKey: Item {
        id: lk
        property string label: ""
        signal pressed()

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            color: "transparent"
            border.color: "#ffffff"
            border.width: 2
            visible: lkMa.pressed
        }
        Text {
            anchors.centerIn: parent
            text: lk.label
            font.family: Theme.mono
            font.pixelSize: 34
            color: "#ffffff"
        }
        MouseArea {
            id: lkMa
            anchors.fill: parent
            onClicked: lk.pressed()
        }
    }

    component CharKey: Item {
        id: ck
        property string label: ""
        signal pressed()
        Text {
            anchors.centerIn: parent
            text: ck.label
            font.family: Theme.mono
            font.pixelSize: 26
            color: "#ffffff"
        }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -10
            onClicked: ck.pressed()
        }
    }

    component IconButton: Item {
        id: ib
        property string kind: ""
        property bool active: false
        signal pressed()
        IconGlyph {
            anchors.centerIn: parent
            kind: ib.kind
            color: "#ffffff"
            size: ib.kind === "globe" ? 28 : 30
            filled: ib.active
        }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            onClicked: ib.pressed()
        }
    }

    // Hand-drawn glyphs (no font icons / no SVG), matches the rest of
    // Scanly which paints all chrome icons via Canvas.
    component IconGlyph: Canvas {
        id: g
        property string kind: ""
        property color color: "#ffffff"
        property real size: 28
        property bool filled: false
        width: g.size; height: g.size
        onColorChanged:  requestPaint()
        onKindChanged:   requestPaint()
        onSizeChanged:   requestPaint()
        onFilledChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.strokeStyle = g.color
            ctx.fillStyle = g.color
            ctx.lineWidth = 2.4
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            const w = width, h = height
            if (g.kind === "undo") {
                ctx.beginPath()
                ctx.moveTo(w * 0.85, h * 0.7)
                ctx.bezierCurveTo(w * 0.8, h * 0.25,
                                  w * 0.45, h * 0.2,
                                  w * 0.18, h * 0.5)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(w * 0.12, h * 0.32)
                ctx.lineTo(w * 0.18, h * 0.5)
                ctx.lineTo(w * 0.34, h * 0.52)
                ctx.stroke()
            } else if (g.kind === "redo") {
                ctx.beginPath()
                ctx.moveTo(w * 0.15, h * 0.7)
                ctx.bezierCurveTo(w * 0.2, h * 0.25,
                                  w * 0.55, h * 0.2,
                                  w * 0.82, h * 0.5)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(w * 0.88, h * 0.32)
                ctx.lineTo(w * 0.82, h * 0.5)
                ctx.lineTo(w * 0.66, h * 0.52)
                ctx.stroke()
            } else if (g.kind === "shift") {
                ctx.beginPath()
                ctx.moveTo(w * 0.5, h * 0.15)
                ctx.lineTo(w * 0.88, h * 0.55)
                ctx.lineTo(w * 0.68, h * 0.55)
                ctx.lineTo(w * 0.68, h * 0.85)
                ctx.lineTo(w * 0.32, h * 0.85)
                ctx.lineTo(w * 0.32, h * 0.55)
                ctx.lineTo(w * 0.12, h * 0.55)
                ctx.closePath()
                if (g.filled) ctx.fill()
                else          ctx.stroke()
            } else if (g.kind === "backspace") {
                // Pentagon body : tall rectangle on the right, arrow tip on the left.
                const bodyL = w * 0.32, bodyR = w * 0.92
                const top = h * 0.18, bot = h * 0.82
                const tipX = w * 0.06, midY = h * 0.5
                ctx.beginPath()
                ctx.moveTo(bodyL, top)
                ctx.lineTo(bodyR, top)
                ctx.lineTo(bodyR, bot)
                ctx.lineTo(bodyL, bot)
                ctx.lineTo(tipX, midY)
                ctx.closePath()
                ctx.stroke()
                // × centered inside the rectangular body
                const cx = (bodyL + bodyR) / 2
                const cy = midY
                const r  = Math.min((bodyR - bodyL), (bot - top)) * 0.28
                ctx.beginPath()
                ctx.moveTo(cx - r, cy - r); ctx.lineTo(cx + r, cy + r)
                ctx.moveTo(cx + r, cy - r); ctx.lineTo(cx - r, cy + r)
                ctx.stroke()
            } else if (g.kind === "enter") {
                // ↵ shape
                ctx.beginPath()
                ctx.moveTo(w * 0.88, h * 0.22)
                ctx.lineTo(w * 0.88, h * 0.52)
                ctx.lineTo(w * 0.22, h * 0.52)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(w * 0.34, h * 0.38)
                ctx.lineTo(w * 0.18, h * 0.52)
                ctx.lineTo(w * 0.34, h * 0.66)
                ctx.stroke()
            } else if (g.kind === "globe") {
                // simple globe (circle + a meridian + an equator)
                ctx.beginPath()
                ctx.arc(w * 0.5, h * 0.5, w * 0.42, 0, Math.PI * 2)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(w * 0.08, h * 0.5)
                ctx.lineTo(w * 0.92, h * 0.5)
                ctx.stroke()
                ctx.beginPath()
                ctx.ellipse(w * 0.3, h * 0.08, w * 0.4, h * 0.84)
                ctx.stroke()
            }
        }
    }
}
