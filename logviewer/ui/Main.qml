import QtQuick
import QtQuick.Controls 
import QtQuick.Layouts 
import QtQuick.Dialogs
import Qt.labs.platform
import QtPositioning
import QtQuick.Controls.Basic as QC

ApplicationWindow {
    id: root
    visible: true
    width: 1024
    height: 768
    title: "LogViewer"

    MenuBar {
        id: menuBar
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
            MenuItem {
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

    About {
        id: aboutDialog
    }

    component SearchInput : QC.TextField {
        id: searchInput
        palette {
            placeholderText: Theme.grayColor
            text: Theme.textMainColor
        }
        rightPadding: padding + searchIcon.width + searchIcon.anchors.rightMargin
        font.pixelSize: Theme.smallFontSize
        font.weight: Theme.fontLightWeight
        background: Rectangle {
            border {
                width: 1
                color:Theme.searchBorderColor
            }
            color: "transparent"
            radius: 3
            Image {
                id: searchIcon
                anchors {
                    right: parent.right
                    rightMargin: Theme.defaultSpacing
                    verticalCenter: parent.verticalCenter
                }
                source: "icons/search.svg"
                sourceSize.height: searchInput.implicitHeight - searchInput.padding * 2
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    component IconButton : QC.ToolButton {
        id: iconButton
        property bool selected: false
        icon.width: 0
        icon.height: 0
        icon.color: selected ? Theme.greenColor : Theme.grayColor
        background: Rectangle {
            border {
                width: 1
                color: iconButton.selected ? Theme.greenColor : Theme.searchBorderColor
            }
            color: "transparent"
            radius: 3
        }
    }

    component MenuPopup : QC.Popup {
        modal: true
        background: Rectangle {
            radius: 8
            color: Theme.backgroundColor
            border {
                width: 1
                color: Theme.separatorColor
            }
        }
    }

        component CheckElement : QC.ItemDelegate {
        id: checkElement

        readonly property int iconSize: font.pixelSize * 2

        checked: true
        padding: 0

        display: QC.AbstractButton.TextBesideIcon

        font.pixelSize: Theme.smallFontSize
        font.weight: Theme.fontLightWeight
        palette.text: checked ? Theme.greenColor : Theme.textSecondaryColor

        icon.source: checked ? "icons/checkbox.svg" : "icons/checkbox_blank.svg"
        icon.height: iconSize
        icon.width: iconSize
        icon.color: checked ? Theme.greenColor : Theme.textSecondaryColor

        LayoutMirroring.enabled: true
        LayoutMirroring.childrenInherit: true

        background: Rectangle {
            anchors.fill: parent
            color: "transparent"
        }

        onClicked: {
            checked = !checked
        }
    }

    Rectangle {
        id: sortAndFilter
        width: root.width
        height: searchField.implicitHeight + sortAndFilterLayout.anchors.margins * 2
        color: Theme.backgroundColor
        RowLayout {
            id: sortAndFilterLayout
            anchors {
                fill: parent
                margins: Theme.defaultSpacing * 2
            }
            spacing: Theme.defaultSpacing * 2
            SearchInput {
                id: searchField
                placeholderText: qsTr("Search")
                Layout.fillWidth: true
                onTextChanged: {
                    console.log("search: ", searchField.text)
                }
            }
            IconButton {
                selected: filterMenu.visible
                icon.source: "icons/filter.svg"
                Layout.preferredHeight: searchField.implicitHeight
                Layout.preferredWidth: Layout.preferredHeight
                onClicked: filterMenu.open()
            }
        }
    }

    Rectangle {
        id: separator
        anchors.top: sortAndFilter.bottom
        color: Theme.separatorColor
        height: 1
        width: root.width
    }

    HorizontalHeaderView {
        id: horizontalHeader
        anchors {
            top: separator.bottom
            left: logTableView.left
            right: parent.right
        }
        syncView: logTableView
        clip: true
        delegate: Rectangle{
          border.color: "#848484"
          color: "white"

          implicitHeight: 32
          Text{
            anchors.fill: parent
            font.pointSize: 12
            font.weight: Font.Bold
            color: "black"
            horizontalAlignment:Text.AlignHCenter
            verticalAlignment:Text.AlignVCenter
            text: model.display
          }
        }
    }

    TableView {
        id: logTableView 
        anchors {
            top: horizontalHeader.bottom
            bottom: parent.bottom
            left: parent.left
            leftMargin: Theme.defaultSpacing * 2
            right: parent.right
        }
        boundsBehavior: Flickable.OvershootBounds
        clip: true
        interactive: true

        columnWidthProvider: function(column) {
            if (column === 0)
                return Constants.timestampWidth;
            else if (column === 1)
                return Constants.threadWidth;
            else if (column === 2)
                return Constants.levelWidth;
            else if (column === 3)
                return Constants.fileWidth;
            else if (column === 4)
                return Constants.lineWidth;
            else if (column === 5)
                return Constants.functionWidth;
            else if (column === 6)
                return root.width - (Constants.totalFixedWidth);
            else 
                return -1
        }

        selectionModel: ItemSelectionModel {
            model: logModel
        }
        selectionBehavior:TableView.SelectRows  // doesn't work, don't know why
        selectionMode:TableView.SingleSelection
        model: logModel 
        // 设置每个单元格的字体样式
        delegate: LogDelegate {
        }

        //这里的滚动条只用于显示，所以设置了enabled: false
        //垂直滚动条

        ScrollBar.vertical: ScrollBarThemed {
            id: logViewVertScrollbar
            topPadding: 36
            policy: ScrollBar.AsNeeded
        }
        ScrollBar.horizontal: ScrollBarThemed {
            policy: ScrollBar.AsNeeded
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Up) {
                var newRow = logTableView.selectionModel.selectedIndexes[0].row - 1;
                if (newRow < 0)
                    newRow = 0;
                logTableView.selectionModel.select(model.index(newRow, 0), 
                    ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Current | ItemSelectionModel.Rows)
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                var newRow = logTableView.selectionModel.selectedIndexes[0].row + 1;
                if (newRow >= model.rowCount())
                    newRow = model.rowCount() - 1;
                logTableView.selectionModel.select(model.index(newRow, 0), 
                    ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Current | ItemSelectionModel.Rows)
                event.accepted = true;
            }
        }

        Shortcut {
            sequences: [StandardKey.Copy]
            onActivated: {
                let indexes = logTableView.selectionModel.selectedIndexes
                logTableView.model.copyToClipboard(indexes)
            }
        }

        Shortcut {
            sequences: [StandardKey.Paste]
            onActivated: {
                let targetIndex = logTableView.selectionModel.currentIndex
                logTableView.model.pasteFromClipboard(targetIndex)
            }
        }
    }

    SelectionRectangle {
        target: logTableView
    }
    // 创建一个 LogModel 实例
    LogModel {
        id: logModel
        Component.onCompleted: {
            // 加载日志文件
            console.log("LogModel completed")
        }
    }

    FileDialog {
        id: fileDialog
        title: "Open Log File"
        nameFilters: ["Log files (*.log)", "All files (*.*)"]
        onAccepted: {
            logModel.loadLogs(fileDialog.file)
        }
    }

    property var filterModel: [
        {"name": "Timestamp"},
        {"name": "thread"},
        {"name": "level"},
        {"name": "message"},
    ]

    MenuPopup {
        id: filterMenu
        x: root.width - filterMenu.width - Theme.defaultSpacing
        y: logTableView.y - Theme.defaultSpacing
        ColumnLayout {
            id: filterLayout
            anchors.fill: parent
            spacing: Theme.defaultSpacing
            Text {
                text: qsTr("filter")
                color: Theme.textMainColor
                font.pixelSize: Theme.mediumFontSize
                font.weight: Theme.fontDefaultWeight
                Layout.alignment: Qt.AlignRight
            }
            //! [0]
            Repeater {
                model: root.filterModel
                delegate: CheckElement {
                    required property var modelData
                    text: modelData.name
                    Layout.alignment: Qt.AlignRight
                    onCheckedChanged: {
                        console.log("checked: ", modelData.name)
                    }
                }
            }
        }
    }


}
