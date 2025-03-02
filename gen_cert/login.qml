import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts

ApplicationWindow {
    width: 1280
    height: 800
    visible: true
    title: "Login"
    id: root
    flags: Qt.FramelessWindowHint | Qt.Window
    color: "#00000000" // 背景透明

    property int dragX: 0
    property int dragY: 0
    property bool dragging: false

    Rectangle {
        width: parent.width
        height: parent.height
        radius: 10 // 圆角
        gradient: Gradient {
            GradientStop {
                position: 0
                color: "#4158d0"
            }
            GradientStop {
                position: 1
                color: "#c850c0"
            }
        }

        MouseArea {
            height: parent.height / 10
            onPressed: {
                root.dragging = true
                root.dragX = mouseX
                root.dragY = mouseY
            }
            onReleased: {
                root.dragging = false
            }
            onPositionChanged: {
                if (root.dragging) {
                    root.x += mouseX - root.dragX
                    root.y += mouseY - root.dragY
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Image {
                    source: "path/to/your/image.png"
                    Layout.preferredWidth: parent.width * 0.4
                    Layout.preferredHeight: parent.height
                    fillMode: Image.PreserveAspectFit
                }

                ColumnLayout {
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: parent.height
                    spacing: 20

                    TextField {
                        placeholderText: "Username"
                        Layout.fillWidth: true
                    }

                    TextField {
                        placeholderText: "Password"
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "Login"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}