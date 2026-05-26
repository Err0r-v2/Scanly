import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import app.scanly

Page {
    id: page
    background: Rectangle { color: Theme.paper }

    function toggleValue(key) {
        if (key === "autoAdvanceChapter")
            return settings.autoAdvanceChapter
        if (key === "forceScreenMode")
            return settings.forceScreenMode
        if (key === "offlineMode")
            return settings.offlineMode
        return false
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 48
        anchors.rightMargin: 48
        anchors.topMargin: 28
        anchors.bottomMargin: 32
        spacing: 0

        Text {
            text: "Settings"
            font.family: Theme.serif
            font.italic: true
            font.weight: Font.DemiBold
            font.pixelSize: 96
            color: Theme.ink
        }
        Text {
            text: "Reading preferences"
            font.family: Theme.mono
            font.pixelSize: 22
            font.letterSpacing: 1.4
            color: Theme.inkMute
            Layout.topMargin: 6
        }

        Hairline { Layout.fillWidth: true; Layout.topMargin: 24; strength: 1.0 }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 28
            spacing: 0

            Repeater {
                model: [
                    {
                        key: "autoAdvanceChapter",
                        label: "Auto-advance to next chapter",
                        hint: "On the last page of a chapter, tapping forward opens the next chapter.",
                    },
                    {
                        key: "forceScreenMode",
                        label: "Force e-ink screen mode",
                        hint: "When off, the reader uses the tablet's native refresh behavior.",
                    },
                    {
                        key: "offlineMode",
                        label: "Offline mode",
                        hint: "Simulate no network: series details only show downloaded chapters, cached covers, and cached synopses.",
                    },
                ]
                delegate: Item {
                    Layout.fillWidth: true
                    implicitHeight: Math.max(124, toggleRow.implicitHeight + 24)

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 2
                        color: Theme.ink
                    }

                    RowLayout {
                        id: toggleRow
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 4
                        anchors.topMargin: 12
                        anchors.bottomMargin: 12
                        spacing: 28

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Text {
                                text: modelData.label
                                font.family: Theme.serif
                                font.pixelSize: 36
                                color: Theme.ink
                            }
                            Text {
                                text: modelData.hint
                                font.family: Theme.serif
                                font.italic: true
                                font.pixelSize: 24
                                color: Theme.inkSoft
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                            }
                        }

                        Item {
                            Layout.preferredWidth: 168
                            Layout.preferredHeight: 60
                            Rectangle {
                                anchors.fill: parent
                                color: page.toggleValue(modelData.key) ? Theme.ink : "transparent"
                                border.color: Theme.ink
                                border.width: 2
                                Text {
                                    anchors.centerIn: parent
                                    text: page.toggleValue(modelData.key) ? "ON" : "OFF"
                                    font.family: Theme.mono
                                    font.pixelSize: 22
                                    font.letterSpacing: 1.4
                                    color: page.toggleValue(modelData.key) ? Theme.paper : Theme.ink
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (modelData.key === "autoAdvanceChapter")
                                        settings.autoAdvanceChapter = !settings.autoAdvanceChapter
                                    else if (modelData.key === "forceScreenMode")
                                        settings.forceScreenMode = !settings.forceScreenMode
                                    else if (modelData.key === "offlineMode")
                                        settings.offlineMode = !settings.offlineMode
                                    epaper.partialRefresh()
                                }
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 36
            spacing: 18

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Text {
                    text: "E-ink screen mode"
                    font.family: Theme.serif
                    font.pixelSize: 36
                    color: Theme.ink
                }
                Text {
                    text: "Picks the EPD waveform used when turning pages. Content keeps tones smooth, Mono is faster and crisper for B&W manga, Animation favors quick partial refreshes."
                    font.family: Theme.serif
                    font.italic: true
                    font.pixelSize: 24
                    color: Theme.inkSoft
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: [
                        { key: "Animation", label: "Animation" },
                        { key: "Mono",      label: "Mono" },
                        { key: "Content",   label: "Content" },
                    ]
                    delegate: Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 76
                        property bool active: settings.screenMode === modelData.key

                        Rectangle {
                            anchors.fill: parent
                            color: settings.forceScreenMode && parent.active ? Theme.ink : "transparent"
                            border.color: Theme.ink
                            border.width: 2
                            opacity: settings.forceScreenMode ? 1.0 : 0.45
                        }
                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            font.family: Theme.mono
                            font.pixelSize: 22
                            font.letterSpacing: 1.2
                            color: settings.forceScreenMode && parent.active ? Theme.paper : Theme.ink
                            opacity: settings.forceScreenMode ? 1.0 : 0.45
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: settings.forceScreenMode
                            onClicked: {
                                settings.screenMode = modelData.key
                                epaper.partialRefresh()
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: cadenceBlock
            Layout.fillWidth: true
            Layout.topMargin: 36
            spacing: 16
            // Cadence only matters for waveforms that leave ghost residue.
            // In Content mode (or when forceScreenMode is off → defaults to
            // Content), every page already does a full GC16 refresh.
            property bool cadenceRelevant: settings.forceScreenMode
                                           && settings.screenMode !== "Content"
            opacity: cadenceRelevant ? 1.0 : 0.45

            RowLayout {
                Layout.fillWidth: true
                spacing: 24

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text {
                        text: "Full refresh cadence"
                        font.family: Theme.serif
                        font.pixelSize: 36
                        color: Theme.ink
                    }
                    Text {
                        text: cadenceBlock.cadenceRelevant
                              ? "Number of turned pages before ghost cleanup runs in the reader."
                              : "Disabled, Content mode already refreshes every page."
                        font.family: Theme.serif
                        font.italic: true
                        font.pixelSize: 24
                        color: Theme.inkSoft
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                }

                Text {
                    text: settings.ghostCleanInterval + " pages"
                    font.family: Theme.mono
                    font.pixelSize: 26
                    font.letterSpacing: 1.0
                    color: Theme.ink
                    Layout.preferredWidth: 150
                    horizontalAlignment: Text.AlignRight
                }
            }

            Slider {
                id: ghostCleanSlider
                Layout.fillWidth: true
                Layout.preferredHeight: 72
                enabled: cadenceBlock.cadenceRelevant
                from: 1
                to: 60
                stepSize: 1
                snapMode: Slider.SnapAlways
                value: settings.ghostCleanInterval
                onMoved: {
                    settings.ghostCleanInterval = Math.round(value)
                    epaper.partialRefresh()
                }

                background: Rectangle {
                    x: ghostCleanSlider.leftPadding
                    y: ghostCleanSlider.topPadding + ghostCleanSlider.availableHeight / 2 - height / 2
                    width: ghostCleanSlider.availableWidth
                    height: 6
                    color: Theme.paperEdge
                    Rectangle {
                        width: ghostCleanSlider.visualPosition * parent.width
                        height: parent.height
                        color: Theme.ink
                    }
                }
                handle: Rectangle {
                    x: ghostCleanSlider.leftPadding + ghostCleanSlider.visualPosition
                       * (ghostCleanSlider.availableWidth - width)
                    y: ghostCleanSlider.topPadding + ghostCleanSlider.availableHeight / 2 - height / 2
                    width: 34
                    height: 34
                    color: Theme.paper
                    border.color: Theme.ink
                    border.width: 3
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 36
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Text {
                    text: "Sources"
                    font.family: Theme.serif
                    font.pixelSize: 36
                    color: Theme.ink
                }
                Text {
                    text: "Pick which scanlation sources Discover searches in parallel. At least one must stay enabled."
                    font.family: Theme.serif
                    font.italic: true
                    font.pixelSize: 24
                    color: Theme.inkSoft
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }

            Repeater {
                model: [
                    { key: "scanmirror",  label: "Anime Sama + Yaoiscan", lang: "French"  },
                    { key: "weebcentral", label: "Weeb Central",          lang: "English" },
                ]
                delegate: Item {
                    id: srcRow
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 96

                    // Re-evaluates whenever the enabled-set changes.
                    readonly property bool active: settings.enabledSources.indexOf(modelData.key) >= 0

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 2
                        color: Theme.ink
                    }

                    Item {
                        id: pill
                        width: 144
                        height: 56
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        Rectangle {
                            anchors.fill: parent
                            color: srcRow.active ? Theme.ink : "transparent"
                            border.color: Theme.ink
                            border.width: 2
                        }
                        Text {
                            anchors.centerIn: parent
                            text: srcRow.active ? "ON" : "OFF"
                            font.family: Theme.mono
                            font.pixelSize: 22
                            font.letterSpacing: 1.4
                            color: srcRow.active ? Theme.paper : Theme.ink
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                settings.toggleSource(srcRow.modelData.key)
                                epaper.partialRefresh()
                            }
                        }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.right: pill.left
                        anchors.rightMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4
                        Text {
                            width: parent.width
                            text: srcRow.modelData.label
                            font.family: Theme.serif
                            font.pixelSize: 30
                            color: Theme.ink
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            text: srcRow.modelData.lang.toUpperCase()
                            font.family: Theme.mono
                            font.pixelSize: 18
                            font.letterSpacing: 1.2
                            color: Theme.inkMute
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
