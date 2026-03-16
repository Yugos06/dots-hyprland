import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    id: dock
    required property QtObject palette
    color: "transparent"

    // Hidden until Quickshell restarts when No Focus is pressed.
    property bool hiddenMode: false
    property bool showIcons: true
    property var dynamicEntries: []
    property bool dockEnabled: true

    readonly property string defaultIcon: "/usr/share/icons/Papirus/24x24/mimetypes/application-x-executable.svg"
    readonly property string iconShow: "/usr/share/icons/Papirus/24x24/actions/view-visible.svg"
    readonly property string iconHide: "/usr/share/icons/Papirus/24x24/actions/view-hidden.svg"
    readonly property string iconAdd: "/usr/share/icons/Papirus/24x24/actions/list-add.svg"
    readonly property string iconRemove: "/usr/share/icons/Papirus/24x24/actions/list-remove.svg"
    readonly property string iconRefresh: "/usr/share/icons/Papirus/24x24/actions/view-refresh.svg"
    readonly property color safeBorder: palette && palette.border ? palette.border : Qt.rgba(1, 1, 1, 0.22)
    readonly property color safeAccentSoft: palette && palette.accentSoft ? palette.accentSoft : Qt.rgba(1, 1, 1, 0.14)
    readonly property color safeBarText: palette && palette.barText ? palette.barText : Qt.rgba(1, 1, 1, 0.85)
    readonly property color dockBg: palette && palette.surface ? palette.surface : Qt.rgba(0.08, 0.09, 0.12, 0.86)
    readonly property color dockBgAlt: palette && palette.surfaceAlt ? palette.surfaceAlt : Qt.rgba(0.12, 0.13, 0.18, 0.9)
    readonly property color dockGlow: palette && palette.accentSoft ? palette.accentSoft : Qt.rgba(0.78, 0.7, 1, 0.16)

    readonly property string customEntriesPath: {
        const u = Qt.resolvedUrl("../../runtime/dock-apps.list").toString();
        return u.startsWith("file://") ? decodeURIComponent(u.slice(7)) : u;
    }
    readonly property string dockDisablePath: {
        const u = Qt.resolvedUrl("../../runtime/disable-dock").toString();
        return u.startsWith("file://") ? decodeURIComponent(u.slice(7)) : u;
    }

    readonly property var coreEntries: [
        {
            label: "Applications",
            iconFile: "/usr/share/icons/Papirus/24x24/actions/homerun.svg",
            command: "$HOME/.config/hypr/scripts/launchers.sh app"
        },
        {
            label: "Terminal",
            iconFile: "/usr/share/icons/Papirus/48x48/apps/kitty.svg",
            command: "kitty"
        },
        {
            label: "Navigateur",
            iconFile: "/usr/share/icons/Papirus/48x48/apps/firefox.svg",
            command: "firefox"
        },
        {
            label: "Fichiers",
            iconFile: "/usr/share/icons/Papirus/48x48/apps/thunar.svg",
            command: "sh -lc 'command -v thunar >/dev/null 2>&1 && exec thunar; command -v nautilus >/dev/null 2>&1 && exec nautilus; exec xdg-open \"$HOME\"'"
        },
        { separator: true },
        {
            label: "Actions",
            iconFile: "/usr/share/icons/Papirus/24x24/actions/system-run.svg",
            command: "$HOME/.config/quickshell/end4-lite/scripts/toggle-launcher.sh"
        },
        {
            label: "Capture",
            iconFile: "/usr/share/icons/Papirus/48x48/apps/accessories-screenshot.svg",
            command: "$HOME/.config/hypr/scripts/screenshot.sh area-copy"
        },
        {
            label: "Verrouiller",
            iconFile: "/usr/share/icons/Papirus/24x24/actions/system-lock-screen.svg",
            command: "hyprlock"
        }
    ]

    readonly property var managementEntries: [
        {
            label: "Add App",
            addDockApp: true
        },
        {
            label: "Remove App",
            removeDockApp: true
        },
        {
            label: "Reload",
            reloadDockApps: true
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

    readonly property var entries: {
        var list = coreEntries.slice(0);
        if (dynamicEntries.length > 0) {
            list.push({ separator: true });
            for (var i = 0; i < dynamicEntries.length; i++) {
                list.push(dynamicEntries[i]);
            }
        }
        list.push({ separator: true });
        for (var j = 0; j < managementEntries.length; j++) {
            list.push(managementEntries[j]);
        }
        return list;
    }

    implicitWidth: dockFrame.width
    implicitHeight: dockFrame.height + dockFrame.anchors.bottomMargin

    function parseDynamicEntries(raw) {
        var out = [];
        var lines = raw.split(/\r?\n/);
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (line.length === 0 || line.charAt(0) === "#") {
                continue;
            }

            var parts = line.split("|");
            var label = "";
            var icon = "";
            var command = "";

            if (parts.length >= 4) {
                label = parts[1].trim();
                icon = parts[2].trim();
                command = parts.slice(3).join("|").trim();
            } else if (parts.length >= 3) {
                label = parts[0].trim();
                icon = parts[1].trim();
                command = parts.slice(2).join("|").trim();
            }

            if (label.length === 0 || command.length === 0) {
                continue;
            }

            out.push({
                label: label,
                iconFile: icon,
                command: command
            });
        }
        dock.dynamicEntries = out;
    }

    function reloadDynamicEntries() {
        readDockApps.running = true;
    }

    function applyDockToggle(raw) {
        dockEnabled = (raw || "").trim() !== "1";
    }

    function launch(command) {
        if (!command || command.length === 0) {
            return;
        }

        Quickshell.execDetached(["sh", "-lc", command]);
    }

    function triggerEntry(entry) {
        if (entry.addDockApp === true) {
            dock.launch("$HOME/.config/quickshell/end4-lite/scripts/dock-apps.sh add");
            return;
        }
        if (entry.removeDockApp === true) {
            dock.launch("$HOME/.config/quickshell/end4-lite/scripts/dock-apps.sh remove");
            return;
        }
        if (entry.reloadDockApps === true) {
            dock.reloadDynamicEntries();
            return;
        }
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
        if (entry.addDockApp === true) {
            return iconAdd;
        }
        if (entry.removeDockApp === true) {
            return iconRemove;
        }
        if (entry.reloadDockApps === true) {
            return iconRefresh;
        }
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

    property Timer dockAppsPoll: Timer {
        interval: 2500
        running: true
        repeat: true
        onTriggered: dock.reloadDynamicEntries()
    }

    property Process readDockApps: Process {
        command: ["sh", "-lc", "cat " + dock.customEntriesPath + " 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: dock.parseDynamicEntries(text)
        }
    }

    property Process readDockToggle: Process {
        command: ["sh", "-lc", "cat " + dock.dockDisablePath + " 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: dock.applyDockToggle(text)
        }
    }

    Component.onCompleted: {
        dock.launch("$HOME/.config/quickshell/end4-lite/scripts/dock-apps.sh refresh");
        reloadDynamicEntries();
        readDockToggle.running = true;
    }

    Rectangle {
        id: dockHalo
        visible: dock.dockEnabled && !dock.hiddenMode
        anchors.centerIn: dockFrame
        width: dockFrame.width + 18
        height: dockFrame.height + 14
        radius: dockFrame.radius + 10
        color: dockGlow
        opacity: 0.45
        z: -1
    }

    Rectangle {
        id: dockFrame
        visible: dock.dockEnabled && !dock.hiddenMode
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        width: row.implicitWidth + 18
        height: 52
        radius: 18
        border.width: 1
        border.color: safeBorder
        gradient: Gradient {
            GradientStop { position: 0.0; color: dockBgAlt }
            GradientStop { position: 1.0; color: dockBg }
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
            spacing: 6

            Repeater {
                model: dock.entries

                delegate: Item {
                    readonly property bool isSeparator: modelData.separator === true
                    readonly property bool visualMode: dock.shouldShowVisual(modelData)
                    width: isSeparator ? 10 : 40
                    height: 36

                    Rectangle {
                        visible: isSeparator
                        width: 1
                        height: 16
                        anchors.centerIn: parent
                        color: safeBorder
                        opacity: 0.85
                    }

                    Rectangle {
                        id: tile
                        visible: !isSeparator
                        anchors.fill: parent
                        radius: 12
                        color: mouseArea.containsMouse ? safeAccentSoft : Qt.rgba(1, 1, 1, 0.04)
                        border.width: mouseArea.containsMouse ? 1 : 0
                        border.color: safeBorder
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
                            width: 20
                            height: 20
                            sourceSize.width: 20
                            sourceSize.height: 20
                            source: dock.iconSource(modelData)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            visible: visualMode && status === Image.Ready
                        }

                        Image {
                            anchors.centerIn: parent
                            width: 18
                            height: 18
                            sourceSize.width: 18
                            sourceSize.height: 18
                            source: dock.defaultIcon
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            visible: visualMode && icon.status !== Image.Ready
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 7
                            height: 7
                            radius: 99
                            color: Qt.alpha(safeBarText, 0.5)
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

    visible: dock.dockEnabled && !dock.hiddenMode
}
