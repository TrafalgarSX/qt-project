import QtQuick
import QtQuick.Controls
import LogViewerConstants

// Wrap the delegate content in a Rectangle so we can set its background color.
Rectangle {
    id: logItem
    // Set background using the hash lookup. If the log level is not found then use "transparent".
    color: Constants.levelColorMap[model.logLevel] !== undefined ? Constants.levelColorMap[model.logLevel] : "transparent"
    width: parent.width
    height: 60

    Row {
        anchors.fill: parent
        anchors.margins: Constants.horizontalMargin
        spacing: 5

        Text {
            text: model.logTimestamp
            width: Constants.timestampWidth
            elide: Text.ElideRight
        }
        Rectangle {
            width: Constants.separatorWidth; color: black
            height: parent.height
        }
        Text {
            text: model.logThread
            width: Constants.threadWidth
            elide: Text.ElideRight
        }
        Rectangle {
            width: Constants.separatorWidth; color: black
            height: parent.height
        }
        Text {
            text: model.logLevel
            width: Constants.levelWidth
            color: "blue"
            elide: Text.ElideRight
        }
        Rectangle {
            width: Constants.separatorWidth; color: black
            height: parent.height
        }
        Text {
            text: model.logMessage
            // Message field uses remaining width from header.
            width: logHeader.width - Constants.totalFixedWidth
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignLeft
        }
    }
}