import QtQuick
import QtQuick.Controls

Rectangle {
    width: 520
    height: 240
    radius: 16
    color: "#0b1220ee"
    border.color: "#7dcfff88"
    border.width: 1

    Column {
        anchors.centerIn: parent
        spacing: 8

        Label {
            text: "Welcome to end4-lite"
            color: "#dbeafe"
            font.bold: true
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
        }
        Label {
            text: "Use SUPER+SHIFT+SPACE to switch theme."
            color: "#93c5fd"
        }
    }
}
