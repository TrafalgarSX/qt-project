/*
    Copyright 2023, Mitch Curtis

    This file is part of Slate.

    Slate is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Slate is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Slate. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls as Controls

Controls.MenuBar {
    spacing: 10
    Component.onCompleted: {
        // 一次性设置宽度，避免绑定循环
        implicitWidth = childrenRect.width + 20
    }
    
    // 新增背景设置圆角
    background: Rectangle {
        anchors.fill: parent
        radius: 10
        color: Theme.darkBackgroundColor  // 根据需要设置背景色
        border.color: "transparent"  // 可选：设置边框颜色
    }

    property var logModel
    property var logTableView
    property var aboutDialog
    property var fileDialog

    Menu {
        id: fileMenu
        title: qsTr("File")

        onClosed: if (logTableView) logTableView.forceActiveFocus()

        MenuItem {
            objectName: "logMenuButton"
            text: qsTr("Open")
            onTriggered: fileDialog.open()
        }

        MenuSeparator {}

        Menu {
            id: recentFilesSubMenu
            objectName: "recentFilesSubMenu"
            title: qsTr("Recent Files")
            // This can use LayoutGroup if it's ever implemented: https://bugreports.qt.io/browse/QTBUG-44078
            width: 400
            enabled: recentFilesInstantiator.count > 0

            onClosed: logTableView.forceActiveFocus()

            Instantiator {
                id: recentFilesInstantiator
                objectName: "recentFilesInstantiator"
                model: settings.recentFiles
                delegate: MenuItem {
                    objectName: text + "MenuItem"
                    text: settings.displayableFilePath(modelData)
                    onTriggered: {
                        // If we load the project immediately, it causes the menu items to be removed immediately,
                        // which means the Menu that owns them will disconnect from the triggered() signal of the
                        // menu item, resulting in the menu not closing:
                        //
                        // https://github.com/mitchcurtis/slate/issues/128
                        //
                        // For some reason, this doesn't happen with native menus, possibly because
                        // the removal and insertion is delayed there.
                        Qt.callLater(function() {
                            logModel.loadLogs(modelData)
                        })
                    }
                }

                onObjectAdded: (index, object) => recentFilesSubMenu.insertItem(index, object)
                onObjectRemoved: (index, object) => recentFilesSubMenu.removeItem(object)
            }

            MenuSeparator {}

            MenuItem {
                objectName: "clearRecentFilesMenuItem"
                //: Empty the list of recent files in the File menu.
                text: qsTr("Clear Recent Files")
                onTriggered: settings.clearRecentFiles()
            }
        }

        MenuSeparator {}

        MenuItem {
            objectName: "quitMenuItem"
            text: qsTr("Quit Logviewer")
            onTriggered: Qt.quit()
        }
    }

    Menu {
        id: toolMenu
        title: qsTr("Tool")

        onClosed: logTableView.forceActiveFocus()

        MenuItem {
            objectName: "logDetailMenuItem"
            //: Empty the list of recent files in the File menu.
            text: qsTr("Log Detail")
            onTriggered: {
                logTableView.toggleLogDetail()
            }
        }
    }

    Menu {
        id: helpMenu
        title: qsTr("Help")

        onClosed: logTableView.forceActiveFocus()

        MenuItem {
            objectName: "aboutMenuItem"
            text: qsTr("About Logviewer")
            onTriggered: aboutDialog.open()
        }
    }


}
