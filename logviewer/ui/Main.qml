import QtQuick
import QtQuick.Controls 
import QtQuick.Layouts 
import QtQuick.Dialogs
import Qt.labs.platform as Platform
import QtPositioning
import QtQuick.Controls.Basic as QC
import QtQuick.Effects

import Logviewer 1.0 as LV

ApplicationWindow {
    id: root
    visibility: Window.Windowed
    width: 1600
    height: 900
    title: "Logviewer"
    color: "transparent" // 背景透明
    flags: Qt.FramelessWindowHint | Qt.Window | Qt.WindowMinimizeButtonHint
    font.family: hacknerd.name  // 设置默认字体
    property bool ftsLoading: true
    property int dotCount: 0
    property string loadingDots: ".".repeat(dotCount)
    property bool logDetailVisible: false

    // 用 NumberAnimation 替代 Timer 自动循环更新 dotCount
    NumberAnimation on dotCount {
        from: 0; to: 10
        duration: 2000
        loops: Animation.Infinite
        running: ftsLoading
    }

    FontLoader {
        id: hacknerd
        source: "qrc:/qt/qml/Logviewer/ui/fonts/HackNerdFont-Regular.ttf" // 字体文件路径在资源文件中
    }

    Rectangle{
        id: mainRect
        anchors.fill: parent
        anchors.margins: 10
        radius: 10 // 圆角

        // 将 MenuBar 移入内部放置在顶部，不再用 ApplicationWindow.menuBar 属性

        Rectangle {
            id: titleBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            implicitHeight: 32
            color: Theme.darkBackgroundColor
            // gradient: Gradient {
            //     GradientStop { position: 0.0; color: "#555555" }
            //     GradientStop { position: 1.0; color: "#AAAAAA" }
            // }
            radius: 10 // 圆角

            LV.MenuBar {

                id: customMenuBar
                anchors {
                    top: parent.top
                    left: parent.left
                }
                // 保持原有绑定
                Component.onCompleted: {
                    customMenuBar.logModel = logModel
                    customMenuBar.aboutDialog = aboutDialog
                    customMenuBar.fileDialog = fileDialog
                    customMenuBar.logTableView = logTableView
                }

            }

            DragHandler {
                id: handler
                onActiveChanged: if (active) root.startSystemMove()
            }
            // Allow fullscreen <-> minimized switching
            MouseArea {
                anchors {
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                    left: customMenuBar.right
                }
                onDoubleClicked: {
                    root.visibility = (root.visibility === Window.Maximized) ? Window.Windowed : Window.Maximized
                }
            }
        }

        Rectangle {
            id: titleSeparator
            anchors.top: titleBar.bottom
            color: Theme.separatorColor
            height: 1
            width: root.width
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
            anchors {
                top: titleBar.bottom
                left: parent.left
                right: parent.right
            }
            width: root.width
            height: searchField.implicitHeight + sortAndFilterLayout.anchors.margins * 2
            color: Theme.backgroundColor
            RowLayout {
                id: sortAndFilterLayout
                anchors {
                    fill: parent
                    margins: Theme.defaultSpacing
                }
                spacing: Theme.defaultSpacing * 2
                SearchInput {
                    id: searchField
                    enabled: !root.ftsLoading
                    placeholderText: root.ftsLoading ?
                                    "Log file is too large; search indexes are loading, please wait" + root.loadingDots :
                                    qsTr("Search: at least 3 characters, press <Enter> to search, Case sensitivity is not currently supported.")
                    Layout.fillWidth: true
                    onEditingFinished: {
                        var fields = []
                        // 从 filterMenu 中收集被选中的搜索字段（假设每个CheckElement的text就是字段名称）
                        for (var i = 0; i < filterLayout.children.length; i++) {
                            var child = filterLayout.children[i]
                            if(child.text && child.checked)
                                fields.push(child.text)
                        }
                        var resultIdx = logModel.searchLogs(searchField.text, fields)
                        if(resultIdx.valid){
                            logTableView.selectionModel.select(resultIdx, ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Current | ItemSelectionModel.Rows)
                            logTableView.selectionModel.setCurrentIndex(resultIdx, ItemSelectionModel.Current)
                            logTableView.positionViewAtRow(resultIdx.row, TableView.Contain)
                        }

                    }
                }
                IconButton {
                    selected: filterMenu.visible
                    icon.source: "icons/filter.svg"
                    Layout.preferredHeight: searchField.implicitHeight
                    Layout.preferredWidth: Layout.preferredHeight
                    onClicked: filterMenu.open()
                }
                IconButton {
                    id: prevSearchResult
                    icon.source: "icons/prev.svg" // replace icon if desired
                    Layout.preferredHeight: searchField.implicitHeight
                    Layout.preferredWidth: Layout.preferredHeight
                    onClicked: {
                        var idx = logModel.prevSearchResult()
                        if(idx.valid){
                            logTableView.selectionModel.select(idx, ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Current | ItemSelectionModel.Rows)
                            logTableView.selectionModel.setCurrentIndex(idx, ItemSelectionModel.Current)
                            logTableView.positionViewAtRow(idx.row, TableView.Contain | TableView.AlignVCenter)
                        }
                    }
                }
                IconButton {
                    id: nextSearchResult
                    icon.source: "icons/next.svg" // replace icon if desired
                    Layout.preferredHeight: searchField.implicitHeight
                    Layout.preferredWidth: Layout.preferredHeight
                    onClicked: {
                        var idx = logModel.nextSearchResult()
                        if(idx.valid){
                            logTableView.selectionModel.select(idx, ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Current | ItemSelectionModel.Rows)
                            logTableView.selectionModel.setCurrentIndex(idx, ItemSelectionModel.Current)
                            logTableView.positionViewAtRow(idx.row, TableView.Contain | TableView.AlignVCenter)
                        }
                    }
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

        // 在标题分隔线下面添加一个新矩形填补表头交叉区域
        Rectangle {
            id: headerCorner
            anchors {
                top: separator.bottom
                left: parent.left
                leftMargin: Theme.defaultSpacing
                right: horizontalHeader.left
            }
            border.color: "lightgrey"
            width: verticalHeader.width
            height: horizontalHeader.height

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(width, height);
                    ctx.strokeStyle = "lightgrey"; // 可以根据需要修改颜色
                    ctx.lineWidth = 1;
                    ctx.stroke();
                }
            }
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
                border.color: "lightgrey"
                color: "white"

                implicitHeight: 32
                Text{
                    anchors.fill: parent
                    font.pointSize: 12
                    font.weight: Font.Bold
                    color: Theme.textMainColor
                    horizontalAlignment:Text.AlignHCenter
                    verticalAlignment:Text.AlignVCenter
                    text: model.display
                }
            }
        }

        VerticalHeaderView {
            id: verticalHeader
            anchors {
                top: logTableView.top
                left: parent.left
                leftMargin: Theme.defaultSpacing
            }
            syncView: logTableView
            clip: true
            delegate: Rectangle{
                border.color: "lightgrey"
                color: "white"

                implicitHeight: 32
                implicitWidth: Math.max(textMetrics.width + 5, 20)
                Text{
                    TextMetrics{
                        id: textMetrics
                        text: model.display
                    }
                    anchors.fill: parent
                    font.pointSize: 9
                    font.weight: Font.Bold
                    color: Theme.textMainColor
                    horizontalAlignment:Text.AlignHCenter
                    verticalAlignment:Text.AlignVCenter
                    text: model.display
                }
            }

        }

        // 在 TableView 上层添加一个透明覆盖层，用于接收拖放事件
        Item {
            id: dropOverlay
            anchors.fill: logTableView
            z: 100  // 确保在顶部
            Rectangle {
                anchors.fill: parent
                id: overlayBg
                color: "transparent"
            }
            DropArea {
                anchors.fill: parent
                // Use a JavaScript function with a formal parameter "drop"
                onDropped: function(drop) {
                    overlayBg.color = "transparent"
                    logModel.loadLogs(drop.urls[0])
                    settings.addRecentFile(drop.urls[0])
                }
                onEntered: {
                    if (drag.urls.length !== 1) { // 过滤事件，只能拖拽一个项目
                        drag.accepted = false 
                        return false;
                    }
                    overlayBg.color = "#3355ff55"  // 半透明蓝色高亮提示
                }
                onExited: {
                    overlayBg.color = "transparent"
                }
            }
        }
        
        TableView {
            id: logTableView 
            anchors {
                top: horizontalHeader.bottom
                left: verticalHeader.right
                right: parent.right
                bottom: parent.bottom
                // Reserve space for logDetailScrollView
                bottomMargin: logDetailVisible ? logDetailScrollView.height : 0
            }
            boundsBehavior: Flickable.OvershootBounds
            clip: true
            interactive: true
            keyNavigationEnabled: false

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
                policy: ScrollBar.AsNeeded
            }
            ScrollBar.horizontal: ScrollBarThemed {
                policy: ScrollBar.AsNeeded
            }

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Up) {
                    var curIdx = logTableView.selectionModel.currentIndex;
                    var newRow = curIdx.row - 1;
                    if (newRow < 0)
                        newRow = 0;
                    logTableView.selectionModel.select(model.index(newRow, 0), 
                        ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Current | ItemSelectionModel.Rows)

                    logTableView.selectionModel.setCurrentIndex(
                        logTableView.model.index(newRow, curIdx.column),
                        ItemSelectionModel.Current
                    );
                    logTableView.positionViewAtRow(newRow, TableView.Contain)
                    event.accepted = true;
                } else if (event.key === Qt.Key_Down) {
                    var curIdx = logTableView.selectionModel.currentIndex;
                    var newRow = curIdx.row + 1;
                    if (newRow >= model.rowCount())
                        newRow = model.rowCount() - 1;

                    logTableView.selectionModel.select(model.index(newRow, 0), 
                        ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Current | ItemSelectionModel.Rows)
                    logTableView.selectionModel.setCurrentIndex(
                        logTableView.model.index(newRow, curIdx.column),
                        ItemSelectionModel.Current
                    );
                    logTableView.positionViewAtRow(newRow, TableView.Contain)
                    event.accepted = true;
                } else if (event.key === Qt.Key_Left) {
                    var curIdx = logTableView.selectionModel.currentIndex;
                    var newCol = curIdx.column - 1;
                    if (newCol < 0)
                        newCol = 0;
                    var newIndex = model.index(curIdx.row, newCol);
                    logTableView.selectionModel.select(
                        newIndex,
                        ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Current
                    );
                    logTableView.selectionModel.setCurrentIndex(
                        logTableView.model.index(curIdx.row, newCol),
                        ItemSelectionModel.Current
                    );
                    event.accepted = true;
                } else if (event.key === Qt.Key_Right) {
                    var curIdx = logTableView.selectionModel.currentIndex;
                    var newCol = curIdx.column + 1;
                    if (newCol >= model.columnCount())
                        newCol = model.columnCount() - 1;
                    var newIndex = model.index(curIdx.row, newCol);
                    logTableView.selectionModel.select(
                        newIndex,
                        ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Current
                    );
                    logTableView.selectionModel.setCurrentIndex(
                        logTableView.model.index(curIdx.row, newCol),
                        ItemSelectionModel.Current
                    );
                    event.accepted = true;
                } else if(event.key === Qt.Key_Tab) {
                    // TODO
                    // searchField.focus = true
                    event.accepted = true
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

            function toggleLogDetail() {
                logDetailVisible = !logDetailVisible
            }
        }

        SelectionRectangle {
            target: logTableView
        }

        // 替换原来的 TextArea 背景设置：使用包裹的 Rectangle 来设置颜色
        ScrollView {
            id: logDetailScrollView
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            width: parent.width
            height: logDetailVisible ? root.height/6 : 0
            Behavior on height {
                NumberAnimation { duration: 200 }
            }

            QC.TextArea {
                id: logDetailArea
                anchors.fill: parent
                readOnly: true
                wrapMode: TextArea.Wrap
                // Ensure the TextArea measures the full width before wrapping lines:
                implicitWidth: parent.width / 2
                text: ""
                background: Rectangle {
                    // anchors.fill: parent
                    color: "#FDF6E3"
                }
            }
            ScrollBar.vertical: ScrollBarThemed {
                policy: ScrollBar.AsNeeded
            }
        }

        property var filterModel: [
            {"name": "timestamp"},
            {"name": "thread"},
            {"name": "level"},
            {"name": "file"},
            {"name": "line"},
            {"name": "message"},
            // {"name": "caseInsensitive"},
        ]

        MenuPopup {
            id: filterMenu
            x: root.width - filterMenu.width - 2 * Theme.defaultSpacing
            y: horizontalHeader.y - Theme.defaultSpacing
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
                    model: mainRect.filterModel
                    delegate: CheckElement {
                        required property var modelData
                        text: modelData.name
                        Layout.alignment: Qt.AlignRight
                        checked: modelData.name === "message" ? true : false
                    }
                }
            }
        }

        // 创建一个 LogModel 实例
        LogModel {
            id: logModel
            Component.onCompleted: {
                // 加载日志文件
                initializeFTSDatabase()
                console.log("LogModel completed")
            }
        }

        FileDialog {
            id: fileDialog
            title: "Open Log File"
            nameFilters: ["Log files (*.txt)", "Log files (*.log)", "All files (*.*)"]
            onAccepted: {
                logModel.loadLogs(selectedFile)
                settings.addRecentFile(selectedFile)
            }
        }

        About {
            id: aboutDialog
            parent: Overlay.overlay
            anchors.centerIn: parent
        }

        Rectangle {
            id: closeButton
            width: 20
            height: 20
            x: root.width - 45; 

            radius: 5
            // 默认背景颜色
            property color normalColor: "white"
            property color hoverColor: "#b1ecec"
            property color pressedColor: "#f53232"
            // 默认颜色绑定
            color: normalColor

            states: [
                State {
                    name: "hovered"
                    when: closeMouseArea.containsMouse && !closeMouseArea.pressed
                    PropertyChanges { target: closeButton; color: hoverColor }
                },
                State {
                    name: "pressed"
                    when: closeMouseArea.pressed
                    PropertyChanges { target: closeButton; color: pressedColor }
                }
            ]
            transitions: Transition {
                ColorAnimation {
                    properties: "color"
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
            Text {
                anchors.centerIn: parent
                text: ""
                font.family: hacknerd.name
                font.pixelSize: 20
            }
            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: { Qt.quit() }
            }
        }


        // 修改 minimizeButton 使用 ColorAnimation 和 easing
        Rectangle {
            id: minimizeButton
            width: 20
            height: 20
            x: root.width - 70; 
            radius: 5
            property color normalColor: "white"
            property color hoverColor: "#b1ecec"
            property color pressedColor: "#f53232"
            color: normalColor

            states: [
                State {
                    name: "hovered"
                    when: minimizeMouseArea.containsMouse && !minimizeMouseArea.pressed
                    PropertyChanges { target: minimizeButton; color: hoverColor }
                },
                State {
                    name: "pressed"
                    when: minimizeMouseArea.pressed
                    PropertyChanges { target: minimizeButton; color: pressedColor }
                }
            ]
            transitions: Transition {
                ColorAnimation {
                    properties: "color"
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
            Text {
                anchors.centerIn: parent
                text: ""
                font.family: hacknerd.name
                font.pixelSize: 20
            }
            MouseArea {
                id: minimizeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: { root.showMinimized() }
            }
        }

    }

    // 修改 MultiEffect 参数，注意 shadowBlur 值和偏移
    MultiEffect {
        id: effect
        anchors.fill: mainRect
        source: mainRect
        shadowEnabled: true
        shadowColor: "lightgrey"
        shadowBlur: 0.5           // 增大模糊半径
        autoPaddingEnabled: true
        shadowHorizontalOffset: 0  // 无偏移
        shadowVerticalOffset: 0   // 无偏移
    }

    Connections {
        target: logModel
        function onFtsUpdateFinished() {
            root.ftsLoading = false;
        }
    }

    Connections {
        target: logTableView.selectionModel
        function onCurrentIndexChanged() {
            if (logTableView.selectionModel.currentIndex.valid && logDetailVisible) {
                logDetailArea.text = logModel.getLogDetail(logTableView.selectionModel.currentIndex.row)
            }
        }
    }
}
