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

    signal testSignal(string msg)

    Rectangle{
        id: mainRect
        anchors.fill: parent
        radius: 10 // 圆角
        color: "white"

        ColumnLayout {
            anchors.fill: parent
            anchors.centerIn: parent
            spacing: 20
            // 实例化 BindProperty 对象
            BindProperty {
                id: bindPropertyObj
                myProperty: "Initial Value"
                onMyPropertyChanged: {
                    console.log("myProperty changed to: " + bindPropertyObj.myProperty)
                }
                Component.onCompleted: {
                    console.log("onCompleted")
                    testBindProperty("Hello from QML!")
                }
            }

            Button {
                id: bindProperty
                text: qsTr("属性绑定")
                implicitHeight: parent.height / 10
                implicitWidth: parent.width / 10
                onClicked: {
                    console.log("test bindProperty")
                    bindPropertyObj.myProperty = "New Value"
                }
            }

            Connections {
                target: rootWindow 
                function onTestSignal(msg) {
                    console.log("mySignal received: " + msg)
                    emitSignalObj.testEmitSignal(msg)
                }
            }

            Button {
                id: emitSignal
                text: qsTr("测试信号")
                implicitHeight: parent.height / 10
                implicitWidth: parent.width / 10
                onClicked: {
                    testSignal("Hello from QML!")
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

    // 定义一个可以被 C++ 调用的函数
    function qmlFunction(message) {
        console.log("QML: qmlFunction called with message: " + message)
    }
}