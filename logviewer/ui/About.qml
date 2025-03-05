import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: aboutDialog
    width: 400
    height: 300
    anchors.centerIn: parent
    title: "About LogViewer"
    modal: true
    standardButtons: Dialog.Ok
    contentItem: ColumnLayout {
         spacing: 10
         
         Label { text: "LogViewer Version 1.0" }
         Label { text: "Developed by Your Company" }
         Label { text: "This application displays and searches log files." }
    }
}