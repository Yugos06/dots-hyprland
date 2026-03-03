import QtQuick
import QtQuick.Controls
import Quickshell

Rectangle {
    id: dock
    required property QtObject palette
    color: "transparent"

    // Hidden until Quickshell restarts when No Focus is pressed.
    property bool hiddenMode: false
    property bool showIcons: true

    readonly property string defaultIcon: "/usr/share/icons/Adwaita/scalable/mimetypes/application-x-executable.svg"
    readonly property string iconShow: "/usr/share/icons/Papirus/24x24/actions/view-visible.svg"
    readonly property string iconHide: "/usr/share/icons/Papirus/24x24/actions/view-hidden.svg"

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
            label: "Icons",
            toggleIcons: true
        },
        {
            label: "No Focus",
            toggleFocus: true
        }
    ]

    implicitWidth: dockFrame.width
    implicitHeight: dockFrame.height + dockFrame.anchors.bottomMargin

    function launch(command) {
        if (!command || command.length === 0) {
            return;
        }

        Quickshell.execDetached(["sh", "-lc", command]);
    }

    function triggerEntry(entry) {
        if (entry.toggleFocus === true) {
            dock.hiddenMode = true;
            return;
        }
        if (entry.toggleIcons === true) {
            dock.showIcons = !dock.showIcons;
            return;
        }
        dock.launch(entry.command);
    }

    function shouldShowVisual(entry) {
        return showIcons || entry.toggleIcons === true || entry.toggleFocus === true;
    }

    function iconSource(entry) {
        if (entry.toggleIcons === true) {
            return showIcons ? iconHide : iconShow;
        }
        if (entry.toggleFocus === true) {
            return iconHide;
        }
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
            GradientStop { position: 0.0; color: "#141414f2" }
            GradientStop { position: 1.0; color: "#090909eb" }
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
                    readonly property bool visualMode: dock.shouldShowVisual(modelData)
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
                            visible: visualMode && status === Image.Ready
                        }

                        Image {
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            sourceSize.width: 16
                            sourceSize.height: 16
                            source: dock.defaultIcon
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            visible: visualMode && icon.status !== Image.Ready
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 6
                            height: 6
                            radius: 99
                            color: Qt.alpha(palette.barText, 0.5)
                            visible: !visualMode
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton
                            preventStealing: true
                            onPressed: function(mouse) {
                                if (mouse.button !== Qt.LeftButton) {
                                    return;
                                }
                                dock.triggerEntry(modelData);
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
