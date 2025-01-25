import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic

ApplicationWindow
{
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

    Rectangle // 背景框
    {
        width: parent.width
        height: parent.height
        radius: 10 // 圆角
        // 窗口拖动
        MouseArea
        {
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
                if (root.dragging)
                {
                    root.x += mouseX - root.dragX
                    root.y += mouseY - root.dragY
                }
            }
        }
        // 背景渐变色
        gradient: Gradient
        {
            GradientStop // start
            {
                position: 0
                color: "#4158d0"
            }
            GradientStop // end
            {
                position: 1
                color: "#c850c0"
            }
            orientation: Gradient.Vertical
        }

        Rectangle // 登录框
        {
            // 居中
            anchors.centerIn: parent
            radius: 10
            color: "#ffffff"
            Image{
                source: ""
            }

            Text
            {
                font.pixelSize: 24
                text: qsTr("登录系统")
                color: "#333333"
            }

            TextField
            {
                id: username
                placeholderText: qsTr("用户名或邮箱")
                placeholderTextColor: "#999999"
                font.pixelSize: 16
                leftPadding: 60
                color: "#666666"
                background: Rectangle
                {
                    color: "#e6e6e6"
                    border.color: "#e6e6e6"
                    radius: 25
                }

                Image
                {
                    source: username.activeFocus ? "qrc:/images/user.png" : "qrc:/images/user.png"
                    width: 30
                    height: 30
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            TextField
            {
                id: password
                placeholderText: qsTr("密码")
                placeholderTextColor: "#999999"
                echoMode: TextInput.Password
                width: username.width
                height: username.height
                font.pixelSize: 16
                leftPadding: username.leftPadding
                color: username.color
                background: Rectangle
                {
                    color: "#e6e6e6"
                    border.color: "#e6e6e6"
                    radius: 25
                }

                Image
                {
                    source: password.activeFocus ? "qrc:/images/user.png" : "qrc:/images/user.png"
                    width: 30
                    height: 30
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Button
            {
                id: submit
                text: qsTr("登录")
                font.pixelSize: 20
                onClicked:
                {
                    console.log("username: " + username.text + ", password: " + password.text)
                }

                background: Rectangle {
                    radius: 25
                    color: {
                        if (submit.down) {
                            return "#00b846"
                        } else if(submit.hovered){
                            return "333333"
                        } else{
                            return "#57b846"
                        }
                    }
                }
            }

        } // login
    } // background

    Rectangle{
        color: "#00000000"
        Text{
            text: "\uea76"
            font.pixelSize: 20
            anchors.centerIn: parent
            MouseArea{
                anchors.fill: parent
                onEntered: {
                    parent.color = "#1BFFFFFF"
                }
                onExited: {
                    parent.color = "#00000000"
                }
                onPressed: {
                    parent.color = "#3BFFFFFF"
                }
                onReleased: {
                    parent.color = "#1BFFFFFF"
                }
                onClicked: {
                    Qt.quit()
                }

            }
        }

    } // close button

} // ApplicationWindow