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
            id: topBarWindow
            required property var modelData
            screen: modelData
            anchors.top: true
            anchors.left: true
            anchors.right: true
            implicitHeight: 42
            color: "transparent"

            Bar.TopBar {
                anchors.fill: parent
                theme: themeBridge
                status: status
            }
        }

        PanelWindow {
            id: rightPanelWindow
            required property var modelData
            screen: modelData
            anchors.top: true
            anchors.right: true
            anchors.bottom: true
            implicitWidth: 360
            margins.top: 54
            margins.right: 10
            margins.bottom: 14
            color: "transparent"

            Panels.RightPanel {
                anchors.fill: parent
                theme: themeBridge
                status: status
            }
        }

        PanelWindow {
            id: bottomDockWindow
            required property var modelData
            screen: modelData
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Top
            anchors.left: true
            anchors.right: true
            anchors.bottom: true
            implicitHeight: bottomDock.hiddenMode ? 0 : 56
            margins.left: 12
            margins.right: 12
            margins.bottom: 4
            color: "transparent"

            Dock.BottomDock {
                id: bottomDock
                anchors.fill: parent
                palette: themeBridge
            }
        }
    }
}
