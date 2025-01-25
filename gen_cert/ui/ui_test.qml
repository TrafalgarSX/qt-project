import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: rootWindow
    visible: true
    height: 600 
    width: 1200
    title: qsTr("证书生成")
    color: "transparent" // 背景透明

    Rectangle{
        id: mainRect
        anchors.fill: parent
        radius: 10 // 圆角
        color: "white"

        ColumnLayout {
            anchors.fill: parent
            anchors.centerIn: parent
            spacing: 20

            Button {
                id: bindProperty
                text: qsTr("属性绑定")
                implicitHeight: parent.height / 10
                implicitWidth: parent.width / 10
                onClicked: {
                    console.log("test bindProperty")
                }
                background: Rectangle {
                    color: "red"
                    radius: 10
                }
            }

            Button {
                id: test2
                text: qsTr("生成签名证书")
                implicitHeight: parent.height / 10
                implicitWidth: parent.width / 10
                onClicked: {
                }
            }

            Button {
                id: test3
                text: qsTr("生成签名证书")
                implicitHeight: parent.height / 10
                implicitWidth: parent.width / 10
                onClicked: {
                }
            }
        }
    }
}