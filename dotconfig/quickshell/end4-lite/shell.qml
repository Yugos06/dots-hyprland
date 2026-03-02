import QtQuick
import QtQuick.Controls
import Quickshell
import "modules/bar" as Bar
import "modules/panels" as Panels
import "services" as Services

ShellRoot {
    id: root

    Services.ThemeBridge {
        id: theme
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
                theme: theme
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
                theme: theme
                status: status
            }
        }
    }
}
