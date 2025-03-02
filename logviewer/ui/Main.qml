import QtQuick.Controls 
import QtQuick.Layouts 
import About.qml
import LogHeader.qml
import LogDelegate.qml

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 768
    title: "LogViewer"

    menuBar: MenuBar {
        Menu {
            title: "File"
            MenuItem {
                text: "Open"
                onTriggered: fileDialog.open()
            }
            MenuItem {
                text: "Open Recent File"
                // Implement recent file handling here.
            }
            MenuItem {
                text: "Exit"
                onTriggered: Qt.quit()
            }
        }
        Menu {
            title: "Search"
            CheckBox {
                id: caseSensitiveCheck
                text: "Case Sensitive"
            }
            MenuItem {
                text: "Filter Timestamp"
                checkable: true
            }
            MenuItem {
                text: "Filter Thread"
                checkable: true
            }
            MenuItem {
                text: "Filter Level"
                checkable: true
            }
            MenuItem {
                text: "Filter Message"
                checkable: true
            }
        }
        Menu {
            title: "Help"
            MenuItem {
                text: "About"
                onTriggered: aboutDialog.open()
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Open Log File"
        nameFilters: ["Log files (*.log)", "All files (*.*)"]
        onAccepted: {
            logModel.loadLogs(fileUrl.toLocalFile())
        }
    }

    // About dialog component.
    Dialog {
        id: aboutDialog
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

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: menuBar.height

        LogHeader {
            id: logHeader
        }

        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignHCenter

            TextField {
                id: searchField
                placeholderText: "Search logs..."
                Layout.fillWidth: true
            }
            RadioButton {
                id: searchUp
                text: "Up"
                checked: true
            }
            RadioButton {
                id: searchDown
                text: "Down"
            }
            Button {
                text: "Search"
                onClicked: {
                    console.log("Search text:", searchField.text,
                                "Direction:", searchUp.checked ? "Up" : "Down",
                                "Case Sensitive:", caseSensitiveCheck.checked)
                    // Insert actual search logic here.
                }
            }
        }

        ScrollView {
            id: scrollArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: logListView
                width: Math.max(scrollArea.width, logHeader.width)
                height: parent.height
                model: logModel  // Assumes "logModel" is exposed as a context property.
                delegate: LogDelegate {}

                interactive: true
                orientation: ListView.Vertical
                flickDeceleration: 2000

                onContentXChanged: {
                    logHeader.x = -contentX
                }
            }
        }
    }
}