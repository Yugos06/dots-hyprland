import QtQuick
import QtQuick.Controls
import Quickshell

Rectangle {
    id: dock
    required property QtObject palette
    color: "transparent"
    property bool hiddenMode: false
    readonly property string defaultIcon: "/usr/share/icons/Adwaita/scalable/mimetypes/application-x-executable.svg"

    readonly property var entries: [
        {
            label: "Applications",
            iconFile: "/usr/share/icons/AdwaitaLegacy/24x24/places/start-here.png",
            command: "$HOME/.config/hypr/scripts/launchers.sh app"
        },
        {
            label: "Terminal",
            iconFile: "/usr/share/icons/hicolor/scalable/apps/kitty.svg",
            command: "kitty"
        },
        {
            label: "Navigateur",
            iconFile: "/usr/share/icons/hicolor/scalable/apps/firefox.svg",
            command: "firefox"
        },
        {
            label: "Fichiers",
            iconFile: "/usr/share/icons/Papirus/24x24/apps/thunar.svg",
            command: "sh -lc 'command -v thunar >/dev/null 2>&1 && exec thunar; command -v nautilus >/dev/null 2>&1 && exec nautilus; exec xdg-open \"$HOME\"'"
        },
        { separator: true },
        {
            label: "Actions",
            iconFile: "/usr/share/icons/AdwaitaLegacy/24x24/legacy/applications-system.png",
            command: "$HOME/.config/quickshell/end4-lite/scripts/toggle-launcher.sh"
        },
        {
            label: "Capture",
            iconFile: "/usr/share/icons/Papirus/24x24/symbolic/apps/accessories-screenshot-symbolic.svg",
            command: "$HOME/.config/hypr/scripts/screenshot.sh area-copy"
        },
        {
            label: "Verrouiller",
            iconFile: "/usr/share/icons/AdwaitaLegacy/24x24/legacy/system-lock-screen.png",
            command: "hyprlock"
        },
        {
            label: "No Focus",
            iconFile: "/usr/share/icons/Papirus/24x24/actions/view-hidden.svg",
            toggleFocus: true
        }
    ]

    function launch(command) {
        if (!command || command.length === 0) {
            return;
        }

        Quickshell.execDetached(["hyprctl", "dispatch", "exec", command]);
    }

    function iconSource(entry) {
        if (entry.iconFile && entry.iconFile.length > 0) {
            return entry.iconFile;
        }
        return defaultIcon;
    }

    Rectangle {
        id: dockFrame
        visible: !dock.hiddenMode
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        width: row.implicitWidth + 14
        height: 42
        radius: 13
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.85)
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#141414f2"
            }
            GradientStop {
                position: 1.0
                color: "#090909eb"
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.08)
        }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: dock.entries

                delegate: Item {
                    readonly property bool isSeparator: modelData.separator === true
                    width: isSeparator ? 8 : 34
                    height: 32

                    Rectangle {
                        visible: isSeparator
                        width: 1
                        height: 16
                        anchors.centerIn: parent
                        color: palette.border
                        opacity: 0.85
                    }

                    Rectangle {
                        id: tile
                        visible: !isSeparator
                        anchors.fill: parent
                        radius: 10
                        color: mouseArea.containsMouse ? palette.accentSoft : Qt.rgba(1, 1, 1, 0.02)
                        border.width: mouseArea.containsMouse ? 1 : 0
                        border.color: Qt.rgba(1, 1, 1, 0.78)
                        scale: mouseArea.pressed ? 0.94 : (mouseArea.containsMouse ? 1.05 : 1.0)

                        Behavior on scale {
                            NumberAnimation {
                                duration: 120
                                easing.type: Easing.OutCubic
                            }
                        }

                        Image {
                            id: icon
                            anchors.centerIn: parent
                            width: 18
                            height: 18
                            sourceSize.width: 18
                            sourceSize.height: 18
                            source: dock.iconSource(modelData)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }

                        Image {
                            id: fallbackIcon
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            sourceSize.width: 16
                            sourceSize.height: 16
                            source: dock.defaultIcon
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            visible: icon.status !== Image.Ready
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton
                            preventStealing: true
                            onClicked: {
                                if (modelData.toggleFocus === true) {
                                    dock.hiddenMode = true;
                                    return;
                                }
                                dock.launch(modelData.command);
                            }
                        }

                        ToolTip.visible: mouseArea.containsMouse
                        ToolTip.text: modelData.label || ""
                        ToolTip.delay: 250
                    }
                }
            }
        }
    }

    visible: !dock.hiddenMode
}
