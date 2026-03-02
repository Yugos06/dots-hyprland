import QtQuick
import QtQuick.Controls

Rectangle {
    id: bar
    required property QtObject theme
    required property QtObject status
    property date now: new Date()
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        radius: 12
        color: theme.surface
        border.color: theme.border
        border.width: 1

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Repeater {
                model: ["Apps", "1", "2", "3", "4", "5"]
                delegate: Rectangle {
                    height: 24
                    width: textItem.implicitWidth + 16
                    radius: 8
                    color: index === 0 ? theme.accentSoft : "transparent"
                    border.color: index === 0 ? theme.border : "transparent"

                    Text {
                        id: textItem
                        anchors.centerIn: parent
                        text: modelData
                        color: theme.barText
                        font.pixelSize: 12
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: Qt.formatTime(bar.now, "HH:mm")
            color: theme.barText
            font.bold: true
            font.pixelSize: 13
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: bar.now = new Date()
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Text {
                text: "CPU " + status.cpu + "%"
                color: theme.mutedText
                font.pixelSize: 12
            }
            Text {
                text: "RAM " + status.memory + "%"
                color: theme.mutedText
                font.pixelSize: 12
            }
            Text {
                text: "NET " + status.network
                color: theme.mutedText
                font.pixelSize: 12
            }
            Text {
                text: "BAT " + status.battery
                color: theme.mutedText
                font.pixelSize: 12
            }
        }
    }
}
