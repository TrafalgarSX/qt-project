pragma Singleton
import QtQuick 

QtObject {
    // Fixed UI widths.
    readonly property int timestampWidth: 150
    readonly property int threadWidth: 100
    readonly property int levelWidth: 80
    readonly property int separatorWidth: 1
    readonly property int horizontalMargin: 10

    // Calculate the total fixed width used by timestamp, thread, level, separators, and margins.
    readonly property int totalFixedWidth: timestampWidth + threadWidth + levelWidth + (separatorWidth * 3) + (horizontalMargin * 2)

    readonly property string black: "black"

    // Log level constants from SPDLOG.
    readonly property int SPDLOG_LEVEL_TRACE: 0
    readonly property int SPDLOG_LEVEL_DEBUG: 1
    readonly property int SPDLOG_LEVEL_INFO: 2
    readonly property int SPDLOG_LEVEL_WARN: 3
    readonly property int SPDLOG_LEVEL_ERROR: 4
    readonly property int SPDLOG_LEVEL_CRITICAL: 5
    readonly property int SPDLOG_LEVEL_OFF: 6


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