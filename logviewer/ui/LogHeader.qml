import QtQuick 
import QtQuick.Controls 
import Constants

Item {
    id: header
    width: parent.width
    height: 40

    Row {
        anchors.fill: parent
        anchors.margins: Constants.horizontalMargin
        spacing: 5

        Text {
            text: "Timestamp"
            font.bold: true
            width: Constants.timestampWidth
            horizontalAlignment: Text.AlignHCenter
        }
        Rectangle {
            width: Constants.separatorWidth; color: black
            height: parent.height
        }
        Text {
            text: "Thread"
            font.bold: true
            width: Constants.threadWidth
            horizontalAlignment: Text.AlignHCenter
        }
        Rectangle {
            width: Constants.separatorWidth; color: black
            height: parent.height
        }
        Text {
            text: "Level"
            font.bold: true
            width: Constants.levelWidth
            horizontalAlignment: Text.AlignHCenter
        }
        Rectangle {
            width: Constants.separatorWidth; color: black
            height: parent.height
        }
        Text {
            text: "Message"
            font.bold: true
            // Use remaining width from header width minus fixed widths.
            width: header.width - Constants.totalFixedWidth
            horizontalAlignment: Text.AlignHCenter
        }
    }
}