pragma Singleton
import QtQuick 

QtObject {
    // Fixed UI widths.
    readonly property int timestampWidth: 200
    readonly property int threadWidth: 60
    readonly property int levelWidth: 60
    readonly property int fileWidth: 80
    readonly property int lineWidth: 50
    readonly property int functionWidth: 100
    readonly property int totalFixedWidth: timestampWidth + threadWidth + levelWidth + fileWidth + lineWidth + functionWidth

    readonly property int separatorWidth: 1
    readonly property int horizontalMargin: 10
    readonly property int colorColumn: 2

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