import QtQuick
import QtQuick.Controls 2 as QC2

// Wrap the delegate content in a Rectangle so we can set its background color.
Rectangle {
    required property bool selected
    required property bool current
    required property var model
    required property int row
    required property int column

    id: tableCellDelegate

    implicitHeight: 32
    border.color: "lightgrey"
    border.width: 1

    color: {
        // Set background using the hash lookup. If the log level is not found then use "transparent".
        // color: Constants.levelColorMap[model.logLevel] !== undefined ? Constants.levelColorMap[model.logLevel] : "transparent"
        let origincolor = "transparent"
        if(column == Constants.colorColumn) {
            origincolor = Constants.levelColorMap[model.display] !== undefined ? Constants.levelColorMap[model.display] : "transparent"
        }

        let c = (selected || current) ? "lightblue" : origincolor
        return c
    }

    TextMetrics {
        id: textMetrics
        text: display
    }

    Text{
        anchors.centerIn: parent
        anchors.fill: parent
        horizontalAlignment: column === Constants.messageColumn ? Text.AlignLeft : Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.weight: (selected || current) ? Font.DemiBold : Font.Normal
        font.pointSize: 10

        textFormat: Text.PlainText
        text: display
        elide: Text.ElideRight
        color: "black"

       MouseArea{
            property bool doubleClickReceived: false

            id: mouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true

            onClicked: {
                // 如果没有双击，就认为是单击：选中整行
                if (!doubleClickReceived) {
                    logTableView.forceActiveFocus();
                    logTableView.selectionModel.select(
                        logTableView.model.index(row, 0),
                        ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Current | ItemSelectionModel.Rows
                    );
                    logTableView.selectionModel.setCurrentIndex(
                        logTableView.model.index(row, column),
                        ItemSelectionModel.NoUpdate
                    );
                }
                doubleClickReceived = false;
            }

            onDoubleClicked: {
                // 双击以后，只选中当前 cell
                doubleClickReceived = true;
                logTableView.forceActiveFocus();
                logTableView.selectionModel.select(
                    logTableView.model.index(row, column),
                    ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Current
                );
                logTableView.selectionModel.setCurrentIndex(
                    logTableView.model.index(row, column),
                    ItemSelectionModel.NoUpdate
                );
            }
        }
        QC2.ToolTip {
            delay: 250
            parent: tableCellDelegate
            visible: mouseArea.containsMouse && display !== "" && textMetrics.width > (tableCellDelegate.width-6)
            contentItem: Text {
                text: display
                color: "#fcfcfc"
            }
            background: Rectangle {
                color: "black"
            }
        }
    }



}
