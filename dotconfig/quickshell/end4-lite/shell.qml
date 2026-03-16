import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "modules/bar" as Bar
import "modules/dock" as Dock
import "modules/panels" as Panels
import "services" as Services

ShellRoot {
    id: root

    Services.ThemeBridge {
        id: themeBridge
    }

    Services.StatusStore {
        id: status
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: leftSettingsWindow
            required property var modelData
            screen: modelData
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "end4-left-settings"
            anchors.top: true
            anchors.left: true
            anchors.bottom: true
            implicitWidth: leftSettingsPanel.implicitWidth
            implicitHeight: modelData.height
            color: "transparent"

            Panels.LeftSettingsPanel {
                id: leftSettingsPanel
                anchors.fill: parent
                theme: themeBridge
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bottomDockWindow
            required property var modelData
            screen: modelData
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "end4-bottom-dock"
            anchors.bottom: true
            anchors.left: true
            implicitWidth: bottomDock.hiddenMode || !bottomDock.dockEnabled ? 0 : bottomDock.implicitWidth
            implicitHeight: bottomDock.hiddenMode || !bottomDock.dockEnabled ? 0 : 64
            margins.left: bottomDock.hiddenMode || !bottomDock.dockEnabled ? 0 : Math.max(0, Math.round((modelData.width - implicitWidth) / 2))
            margins.bottom: 8
            color: "transparent"

            Dock.BottomDock {
                id: bottomDock
                anchors.fill: parent
                palette: themeBridge
            }
        }
    }
}
