import QtQuick
import QtQuick.Controls

Popup {
    id: popup
    width: 300
    height: 120
    modal: false
    focus: false

    background: Rectangle {
        radius: 12
        color: "#111827ee"
        border.color: "#7dcfff88"
        border.width: 1
    }

    contentItem: Label {
        text: "Configuration rechargee"
        color: "#e5e7eb"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
