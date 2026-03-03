import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: panel
    required property QtObject theme

    property bool pinned: false
    property bool animationsEnabled: true
    property bool blurEnabled: true
    property bool forcedOpen: false

    readonly property color textStrong: "#e8ebf1"
    readonly property color textMuted: "#9ba6b7"
    readonly property color accentTone: "#8fa2b8"
    readonly property color frameBorder: Qt.rgba(1, 1, 1, 0.14)
    readonly property color innerStroke: Qt.rgba(1, 1, 1, 0.09)
    readonly property color cardBg: Qt.rgba(0.09, 0.10, 0.13, 0.90)
    readonly property color cardBorder: Qt.rgba(1, 1, 1, 0.13)
    readonly property color heroBg: Qt.rgba(0.11, 0.13, 0.17, 0.94)
    readonly property color heroBorder: Qt.rgba(0.56, 0.64, 0.72, 0.46)
    readonly property color buttonBorderIdle: Qt.rgba(1, 1, 1, 0.16)
    readonly property color buttonBorderHover: Qt.rgba(0.56, 0.64, 0.72, 0.62)
    readonly property color buttonBgIdle: Qt.rgba(1, 1, 1, 0.05)
    readonly property color buttonBgHover: Qt.rgba(0.56, 0.64, 0.72, 0.18)
    readonly property color buttonBgDown: Qt.rgba(0.56, 0.64, 0.72, 0.28)

    readonly property string toggleStatePath: {
        const u = Qt.resolvedUrl("../../runtime/left-settings.state").toString();
        return u.startsWith("file://") ? decodeURIComponent(u.slice(7)) : u;
    }

    readonly property int edgeWidth: 0
    readonly property int expandedWidth: 368
    readonly property bool hovered: false
    readonly property bool expanded: pinned || forcedOpen

    implicitWidth: expanded ? expandedWidth : 0
    implicitHeight: 720
    clip: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    function run(command) {
        if (!command || command.length === 0) {
            return;
        }

        Quickshell.execDetached(["sh", "-lc", command]);
    }

    function applyExternalToggle(raw) {
        forcedOpen = (raw || "").trim() === "1";
    }

    function reloadExternalToggle() {
        toggleRead.running = true;
    }

    component ActionButton: Button {
        id: control
        property string command: ""

        implicitHeight: 36

        onClicked: {
            if (command.length > 0) {
                panel.run(command);
            }
        }

        contentItem: Text {
            text: control.text
            color: panel.textStrong
            font.pixelSize: 12
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            radius: 10
            border.width: 1
            border.color: control.hovered ? panel.buttonBorderHover : panel.buttonBorderIdle
            color: control.down ? panel.buttonBgDown : (control.hovered ? panel.buttonBgHover : panel.buttonBgIdle)
        }
    }

    Timer {
        interval: 300
        running: true
        repeat: true
        onTriggered: panel.reloadExternalToggle()
    }

    Process {
        id: toggleRead
        command: ["cat", panel.toggleStatePath]
        stdout: StdioCollector {
            onStreamFinished: panel.applyExternalToggle(text)
        }
    }

    Rectangle {
        id: contentFrame
        width: Math.max(0, parent.width - 2)
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 54
        anchors.bottomMargin: 14
        x: expanded ? 2 : -(width + 10)
        radius: 18
        border.width: 1
        border.color: frameBorder
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.09, 0.10, 0.14, 0.96) }
            GradientStop { position: 0.5; color: Qt.rgba(0.06, 0.07, 0.10, 0.95) }
            GradientStop { position: 1.0; color: Qt.rgba(0.03, 0.04, 0.06, 0.93) }
        }
        clip: true
        opacity: 1

        Behavior on x {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.width: 1
            border.color: innerStroke
        }

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Rectangle {
                width: parent.width
                height: 64
                radius: 12
                color: heroBg
                border.width: 1
                border.color: heroBorder

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 2

                    Text {
                        text: "Control Center"
                        color: textStrong
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Text {
                        text: "Utilise SUPER+ALT+S pour ouvrir/fermer"
                        color: textMuted
                        font.pixelSize: 11
                    }
                }
            }

            ScrollView {
                id: scroll
                width: parent.width
                height: parent.height - 74
                clip: true
                contentWidth: availableWidth

                Column {
                    width: scroll.availableWidth
                    spacing: 12

                    Rectangle {
                        width: parent.width
                        radius: 12
                        color: cardBg
                        border.width: 1
                        border.color: cardBorder
                        implicitHeight: behaviorColumn.implicitHeight + 18

                        Column {
                            id: behaviorColumn
                            width: parent.width - 18
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                text: "Comportement"
                                color: textStrong
                                font.bold: true
                                font.pixelSize: 13
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: animationsEnabled ? "Animations ON" : "Animations OFF"
                                    onClicked: {
                                        panel.animationsEnabled = !panel.animationsEnabled;
                                        panel.run("hyprctl keyword animations:enabled " + (panel.animationsEnabled ? "1" : "0"));
                                    }
                                }

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: blurEnabled ? "Blur ON" : "Blur OFF"
                                    onClicked: {
                                        panel.blurEnabled = !panel.blurEnabled;
                                        panel.run("hyprctl keyword decoration:blur:enabled " + (panel.blurEnabled ? "1" : "0"));
                                    }
                                }
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: pinned ? "Unpin Menu" : "Pin Menu"
                                    onClicked: panel.pinned = !panel.pinned
                                }

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Reload Hyprland"
                                    command: "hyprctl reload"
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        radius: 12
                        color: cardBg
                        border.width: 1
                        border.color: cardBorder
                        implicitHeight: filesColumn.implicitHeight + 18

                        Column {
                            id: filesColumn
                            width: parent.width - 18
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                text: "Fichiers"
                                color: textStrong
                                font.bold: true
                                font.pixelSize: 13
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Config"
                                    command: "xdg-open \"$HOME/.config\""
                                }

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Wallpapers"
                                    command: "xdg-open \"$HOME/.config/wallpapers\""
                                }
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Home"
                                    command: "xdg-open \"$HOME\""
                                }

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Downloads"
                                    command: "xdg-open \"$HOME/Downloads\""
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        radius: 12
                        color: cardBg
                        border.width: 1
                        border.color: cardBorder
                        implicitHeight: audioColumn.implicitHeight + 18

                        Column {
                            id: audioColumn
                            width: parent.width - 18
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                text: "Son"
                                color: textStrong
                                font.bold: true
                                font.pixelSize: 13
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Volume -5"
                                    command: "pamixer -d 5"
                                }

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Volume +5"
                                    command: "pamixer -i 5"
                                }
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Mute"
                                    command: "pamixer -t"
                                }

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Mixer"
                                    command: "pavucontrol"
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        radius: 12
                        color: cardBg
                        border.width: 1
                        border.color: cardBorder
                        implicitHeight: displayColumn.implicitHeight + 18

                        Column {
                            id: displayColumn
                            width: parent.width - 18
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                text: "Ecran"
                                color: textStrong
                                font.bold: true
                                font.pixelSize: 13
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Luminosite -10"
                                    command: "brightnessctl s 10%-"
                                }

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Luminosite +10"
                                    command: "brightnessctl s +10%"
                                }
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Wallpaper Menu"
                                    command: "$HOME/.config/hypr/scripts/wallpaper-menu.sh"
                                }

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Capture Zone"
                                    command: "$HOME/.config/hypr/scripts/screenshot.sh area-copy"
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        radius: 12
                        color: cardBg
                        border.width: 1
                        border.color: cardBorder
                        implicitHeight: sessionColumn.implicitHeight + 18

                        Column {
                            id: sessionColumn
                            width: parent.width - 18
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                text: "Session"
                                color: textStrong
                                font.bold: true
                                font.pixelSize: 13
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Show Dock/Bar"
                                    command: "$HOME/.config/hypr/scripts/start-shell.sh"
                                }

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Verrouiller"
                                    command: "hyprlock"
                                }
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Actions Menu"
                                    command: "$HOME/.config/quickshell/end4-lite/scripts/toggle-launcher.sh"
                                }

                                ActionButton {
                                    width: (parent.width - parent.spacing) / 2
                                    text: "Eteindre"
                                    command: "systemctl poweroff"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
