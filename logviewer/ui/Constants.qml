pragma Singleton
import QtQuick 

QtObject {
    // Fixed UI widths.
    readonly property int timestampWidth: 180
    readonly property int threadWidth: 55
    readonly property int levelWidth: 50
    readonly property int fileWidth: 180
    readonly property int lineWidth: 50
    readonly property int totalFixedWidth: timestampWidth + threadWidth + levelWidth + fileWidth + lineWidth

    readonly property int separatorWidth: 1
    readonly property int horizontalMargin: 10

    readonly property int colorColumn: 2 // levelColumn
    readonly property int messageColumn: 5  

    readonly property string displayRoleName: "display"

    // A hash table mapping log level string to background color.
    // Adjust the keys as they appear in your log file.
    readonly property var levelColorMap: {
         "trace": "transparent",
         "debug": "transparent",
         "info": "transparent",
         "warn": "yellow",
         "error": "red",
         "critical": "red",
         "off": "transparent"
    }
}