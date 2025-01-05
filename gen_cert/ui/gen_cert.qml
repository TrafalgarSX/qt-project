import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt.labs.platform
import "utils.js" as Utils

ApplicationWindow {
    id: rootWindow
    visible: true
    height: 600 
    width: 1200
    title: qsTr("证书生成")
    // color: "#00000000" // 背景透明
    color: "transparent" // 背景透明

    flags: Qt.FramelessWindowHint | Qt.Window

    property string currentFolderTarget: ""

    Rectangle{
        id: mainRect
        anchors.fill: parent
        radius: 10 // 圆角

        ColumnLayout {
            id: topLayout
            anchors.fill: parent
            clip: true // 剪裁超出边界的内容

            // Menu bar in top portion of the window, with a visible frame around it
            Rectangle {
                implicitHeight: 20
                Layout.fillWidth: true
                color: "transparent" // 背景透明

                // Allow window dragging when inside menu bar
                Item {
                    anchors.fill: parent
                    DragHandler {
                        id: handler
                        onActiveChanged: if (active) rootWindow.startSystemMove()
                    }
                }

                // Allow fullscreen <-> minimized switching
                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: {
                        rootWindow.visibility = (rootWindow.visibility != Qt.WindowFullScreen) ? Qt.WindowFullScreen : Qt.WindowMinimized
                    }
                }

            }

            GroupBox {
                id: signCertbox
                title: qsTr("签名证书")
                Layout.fillWidth: true   // 水平方向充满
                Layout.fillHeight: true  // 垂直方向充满

                GridLayout {
                    id: gridLayout
                    anchors.fill: parent
                    anchors.rightMargin: 12
                    layer.enabled: false
                    rows: 3
                    columns: 2

                    Label {
                        id: signPubKeyLabel
                        text: qsTr("签名公钥:")
                        verticalAlignment: Text.AlignVCenter // 垂直居中
                        Layout.preferredHeight: parent.height / 7
                        font.styleName: "Regular"
                        Layout.fillHeight: false
                        Layout.fillWidth: false
                        font.bold: true
                        font.weight: Font.Bold
                        Layout.row: 0
                        Layout.column: 0
                    }

                    TextField {
                        id: signPubKeyHex
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height / 7
                        verticalAlignment: Text.AlignVCenter
                        placeholderText: qsTr("请输入16进制字符串")
                        Layout.row: 0
                        Layout.column: 1
                        onTextChanged: {
                            if (!Utils.isHexString(signPubKeyHex.text)) {
                                signPubKeyHex.color = "red"
                            } else {
                                signPubKeyHex.color = "black"
                            }
                        }
                    }

                    Label {
                        id: signPubKeyPathLabel
                        text: qsTr("签名证书保存路径:")
                        verticalAlignment: Text.AlignVCenter // 垂直居中
                        Layout.preferredHeight: parent.height / 7
                        font.bold: true
                        font.weight: Font.Bold
                        Layout.row: 1
                        Layout.column: 0
                    }

                    TextField {
                        id: signPubKeyPath
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height / 7
                        verticalAlignment: Text.AlignVCenter
                        placeholderText: qsTr("请输入存储目录")
                        Layout.row: 1
                        Layout.column: 1
                    }

                    Rectangle {
                        id: signBtnRect
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        Layout.row: 2
                        Layout.preferredHeight: parent.height / 7

                        Button {
                            id: signSelectDir
                            text: qsTr("选择保存路径")
                            anchors.verticalCenter: parent.verticalCenter // 仅垂直居中
                            height: parent.height
                            width: parent.width / 6
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width / 4
                            onClicked: {
                                rootWindow.currentFolderTarget = "sign"
                                fileDialog.open()
                            }
                        }

                        Button {
                            id: genSignCert
                            text: qsTr("生成签名证书")
                            anchors.verticalCenter: parent.verticalCenter // 仅垂直居中
                            height: parent.height
                            width: parent.width / 6
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width / 4
                            onClicked: {
                                if(signPubKeyHex.text === "") {
                                    failureDialog.text = qsTr("签名公钥不能为空！")
                                    failureDialog.open()
                                    return
                                }
                                if(signPubKeyPath.text === "") {
                                    failureDialog.text = qsTr("签名公钥保存路径不能为空！")
                                    failureDialog.open()
                                    return
                                }

                                var success = genCertHelper.genCert(signPubKeyHex.text, signPubKeyPath.text)
                                if(success) {
                                    successDialog.text = qsTr("签名证书生成成功！")
                                    successDialog.open()
                                }else{
                                    successDialog.text = qsTr("签名证书生成失败！")
                                    failureDialog.open()
                                }
                            }
                        }
                    }
                }
            }
            GroupBox {
                id: encCertbox
                title: qsTr("加密证书")
                Layout.fillWidth: true   // 水平方向充满
                Layout.fillHeight: true  // 垂直方向充满
                GridLayout {
                    id: encGridLayout
                    anchors.fill: parent
                    anchors.rightMargin: 12
                    layer.enabled: false
                    rows: 3
                    columns: 2

                    Label {
                        id: encPubKeyLabel
                        text: qsTr("加密公钥:")
                        verticalAlignment: Text.AlignVCenter // 垂直居中
                        Layout.preferredHeight: parent.height / 7
                        font.styleName: "Regular"
                        font.weight: Font.Bold
                        font.bold: true
                        Layout.row: 0
                        Layout.column: 0
                    }

                    TextField {
                        id: encPubKeyHex
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height / 7
                        verticalAlignment: Text.AlignVCenter
                        placeholderText: qsTr("请输入16进制字符串")
                        Layout.row: 0
                        Layout.column: 1
                        onTextChanged: {
                            if (!Utils.isHexString(encPubKeyHex.text)) {
                                encPubKeyHex.color = "red"
                            } else {
                                encPubKeyHex.color = "black"
                            }
                        }
                    }

                    Label {
                        id: encPubKeyPathLabel
                        text: qsTr("加密证书保存路径:")
                        verticalAlignment: Text.AlignVCenter // 垂直居中
                        font.bold: true
                        Layout.row: 1
                        Layout.column: 0
                    }

                    TextField {
                        id: encPubKeyPath
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height / 7
                        verticalAlignment: Text.AlignVCenter
                        placeholderText: qsTr("请输入存储目录")
                        Layout.row: 1
                        Layout.column: 1
                    }

                    Rectangle {
                        id: encBtnRect
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        Layout.row: 2
                        Layout.preferredHeight: parent.height / 7
                        Button {
                            id: encSelectDir
                            text: qsTr("选择保存路径")
                            anchors.verticalCenter: parent.verticalCenter // 仅垂直居中
                            width: parent.width / 6
                            height: parent.height
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width / 4
                            onClicked: {
                                rootWindow.currentFolderTarget = "enc"
                                fileDialog.open()
                            }
                        }

                        Button {
                            id: genEncCert
                            text: qsTr("生成加密证书")
                            anchors.verticalCenter: parent.verticalCenter // 仅垂直居中
                            height: parent.height
                            width: parent.width / 6
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width / 4
                            onClicked: {
                                if(encPubKeyHex.text === "") {
                                    failureDialog.text = qsTr("加密公钥不能为空！")
                                    failureDialog.open()
                                    return
                                }
                                if(encPubKeyPath.text === "") {
                                    failureDialog.text = qsTr("加密公钥保存路径不能为空！")
                                    failureDialog.open()
                                    return
                                }

                                var success = genCertHelper.genCert(encPubKeyHex.text, encPubKeyPath.text)
                                if(success) {
                                    successDialog.text = qsTr("加密证书生成成功！")
                                    successDialog.open()
                                }else{
                                    successDialog.text = qsTr("加密证书生成失败！")
                                    failureDialog.open()
                                }
                            }
                        }
                    }
                }
            }
            FileDialog {
                id: fileDialog
                title: qsTr("选择保存路径")
                folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
                fileMode: FileDialog.SaveFile
                nameFilters: ["cert files (*.pem *.crt)"]
                onAccepted: {
                    if (rootWindow.currentFolderTarget === "sign") {
                        signPubKeyPath.text = fileDialog.file
                    } else {
                        encPubKeyPath.text = fileDialog.file
                    }
                }
            }

            MessageDialog {
                id: successDialog
                title: qsTr("成功")
                buttons: MessageDialog.Ok
            }

            MessageDialog {
                id: failureDialog
                title: qsTr("失败")
                buttons: MessageDialog.Ok
            }

        }

    } // main rect

    Rectangle{
        color: "#00000000"
        x: rootWindow.width - 20
        y: 10
        Text{
            text: "\uf00d"
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