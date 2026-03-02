import QtQuick
import QtQuick.Controls

Rectangle {
    id: panel
    required property QtObject theme
    required property QtObject status
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: theme.surface
        border.color: theme.border
        border.width: 1
    }

    Column {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Rectangle {
            width: parent.width
            height: 120
            radius: 12
            color: theme.surfaceAlt
            border.color: theme.border
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    text: "Now Playing"
                    color: theme.mutedText
                    font.pixelSize: 12
                }
                Text {
                    text: status.mediaTitle
                    color: theme.barText
                    font.bold: true
                    font.pixelSize: 14
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }
                Text {
                    text: status.mediaArtist.length > 0 ? status.mediaArtist : "No artist"
                    color: theme.mutedText
                    font.pixelSize: 12
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }

                Rectangle {
                    width: parent.width
                    height: 6
                    radius: 999
                    color: theme.accent2Soft
                    Rectangle {
                        width: parent.width * 0.35
                        height: parent.height
                        radius: 999
                        color: theme.accent
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            radius: 12
            color: theme.surfaceAlt
            border.color: theme.border
            border.width: 1
            height: parent.height - 132

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "Notifications"
                    color: theme.barText
                    font.bold: true
                    font.pixelSize: 13
                }

                Text {
                    text: status.notifications > 0 ? (status.notifications + " notifications") : "Aucune notification"
                    color: theme.mutedText
                    font.pixelSize: 12
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: theme.border
                }

                Text {
                    text: "Systeme"
                    color: theme.barText
                    font.bold: true
                    font.pixelSize: 12
                }
                Text {
                    text: "CPU: " + status.cpu + "% | RAM: " + status.memory + "%"
                    color: theme.mutedText
                    font.pixelSize: 12
                }
                Text {
                    text: "Reseau: " + status.network + " | Batterie: " + status.battery
                    color: theme.mutedText
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
