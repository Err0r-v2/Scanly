import QtQuick
import QtQuick.Layouts
import app.scanly

Item {
    id: bar
    property string section: "Scanly"
    property string crumb: ""
    implicitHeight: 72

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 2
        color: Theme.ink
        opacity: 1
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 44
        anchors.rightMargin: 44
        spacing: 18

        Text {
            text: bar.section.toUpperCase()
            font.family: Theme.mono
            font.pixelSize: 24
            font.letterSpacing: 1.8
            color: Theme.inkMute
        }
        Text {
            visible: bar.crumb !== ""
            text: "/"
            font.family: Theme.mono
            font.pixelSize: 24
            color: Theme.inkMute
            opacity: 1
        }
        Text {
            visible: bar.crumb !== ""
            text: bar.crumb.toUpperCase()
            font.family: Theme.mono
            font.pixelSize: 24
            font.letterSpacing: 1.8
            color: Theme.inkMute
        }
        Item { Layout.fillWidth: true }
        Text {
            text: device.currentTime
            font.family: Theme.mono
            font.pixelSize: 24
            font.letterSpacing: 1.8
            color: Theme.inkMute
        }
        Canvas {
            id: wifiIcon
            width: 34; height: 24
            Layout.alignment: Qt.AlignVCenter
            property bool online: device.online
            onOnlineChanged: requestPaint()
            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                ctx.strokeStyle = wifiIcon.online ? Theme.inkMute : Theme.inkFaint;
                ctx.lineWidth = 2.0;
                ctx.lineCap = "round";
                for (let i = 0; i < 3; i++) {
                    const r = 14.0 - i * 4.5;
                    ctx.beginPath();
                    ctx.arc(17, 23, r, Math.PI + 0.5, 2 * Math.PI - 0.5);
                    ctx.stroke();
                }
                ctx.fillStyle = wifiIcon.online ? Theme.inkMute : Theme.inkFaint;
                ctx.beginPath();
                ctx.arc(17, 23, 2.0, 0, 2 * Math.PI);
                ctx.fill();
                if (!wifiIcon.online) {
                    ctx.strokeStyle = Theme.seal;
                    ctx.lineWidth = 2.2;
                    ctx.beginPath();
                    ctx.moveTo(4, 4); ctx.lineTo(30, 22);
                    ctx.stroke();
                }
            }
        }
        Text {
            visible: device.batteryPercent >= 0
            text: device.batteryPercent + "%"
            font.family: Theme.mono
            font.pixelSize: 24
            font.letterSpacing: 0.4
            color: device.batteryPercent < 15 && !device.batteryCharging
                   ? Theme.seal : Theme.inkMute
        }
        Canvas {
            id: battIcon
            width: 44; height: 22
            Layout.alignment: Qt.AlignVCenter
            property int pct: Math.max(0, Math.min(100, device.batteryPercent))
            property bool charging: device.batteryCharging
            onPctChanged: requestPaint()
            onChargingChanged: requestPaint()
            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                const low = battIcon.pct < 15 && !battIcon.charging;
                const c = low ? Theme.seal : Theme.inkMute;
                ctx.strokeStyle = c;
                ctx.lineWidth = 2.0;
                ctx.strokeRect(1, 1, 34, 20);
                const fillW = battIcon.pct >= 0 ? (24 * battIcon.pct / 100) : 0;
                ctx.fillStyle = c;
                ctx.fillRect(5, 5, fillW, 12);
                ctx.beginPath();
                ctx.moveTo(38, 6); ctx.lineTo(38, 16);
                ctx.stroke();
                if (battIcon.charging) {
                    ctx.strokeStyle = Theme.seal;
                    ctx.lineWidth = 2.0;
                    ctx.beginPath();
                    ctx.moveTo(19, 3);
                    ctx.lineTo(14, 11);
                    ctx.lineTo(19, 11);
                    ctx.lineTo(15, 19);
                    ctx.stroke();
                }
            }
        }
    }
}
