import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window

Dialog {
    id: root
    objectName: "aboutDialog"
    title: qsTr("About Logviewer")
    modal: true
    dim: false
    focus: true
    standardButtons: Dialog.Ok
    width: Math.max(implicitWidth, 340)

    ColumnLayout {
        spacing: 12

        Label {
            text: qsTr("LogViewer Version 0.1")
            font.bold: true
            font.pixelSize: 12
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: qsTr("This application displays and searches log files.")
            font.pixelSize: 12
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: qsTr("Built from MSVC2022")
            font.pixelSize: 12
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: qsTr("Built with Qt 6.8")
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: qsTr("Copyright 2025, Trafalgar")
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
