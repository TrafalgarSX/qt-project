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
        }

        Label {
            text: qsTr("This application displays and searches log files.")
            font.pixelSize: 12
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Built from MSVC2022")
            font.pixelSize: 12
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Built with Qt 6.8")
        }

        Label {
            text: qsTr("Copyright 2025, Trafalgar")
        }
    }
}
