import QtQuick
import QtQuick.Controls

Dialog {
    id: dialog
    title: "Fermer la session"
    modal: true

    standardButtons: Dialog.Ok | Dialog.Cancel

    contentItem: Label {
        text: "Voulez-vous quitter Quickshell ?"
        color: "#e5e7eb"
        padding: 12
    }
}
