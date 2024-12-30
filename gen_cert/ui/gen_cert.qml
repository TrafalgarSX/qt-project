import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt.labs.platform
import "utils.js" as Utils

ApplicationWindow {
    visible: true
    height: 600 
    width: 1200
    title: qsTr("证书生成")
    color: "white"

    property string currentFolderTarget: ""

    ColumnLayout {
        id: topLayout
        anchors.fill: parent
        clip: true // 剪裁超出边界的内容
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
                            currentFolderTarget = "sign"
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
                            if(encPubKeyHex.text === "") {
                                failureDialog.text = qsTr("签名公钥不能为空！")
                                failureDialog.open()
                            }
                            if(encPubKeyPath.text === "") {
                                failureDialog.text = qsTr("签名公钥保存路径不能为空！")
                                failureDialog.open()
                            }

                            var success = genCertHelper.genCert(signPubKeyHex.text, signPubKeyPath.text)
                            if(success) {
                                successDialog.open()
                            }else{
                                errorDialog.open()
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
                            currentFolderTarget = "enc"
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
                            }
                            if(encPubKeyPath.text === "") {
                                failureDialog.text = qsTr("加密公钥保存路径不能为空！")
                                failureDialog.open()
                            }

                            var success = genCertHelper.genCert(encPubKeyHex.text, encPubKeyPath.text)
                            if(success) {
                                successDialog.open()
                            }else{
                                errorDialog.open()
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
                if (currentFolderTarget === "sign") {
                    signPubKeyPath.text = fileDialog.file.toString().replace("file://", "")
                } else {
                    encPubKeyPath.text = fileDialog.file.toString().replace("file://", "")
                }
            }
        }

        MessageDialog {
            id: successDialog
            title: qsTr("成功")
            text: qsTr("证书生成成功！")
            buttons: MessageDialog.Ok
        }

        MessageDialog {
            id: failureDialog
            title: qsTr("失败")
            text: qsTr("证书生成失败！")
            buttons: MessageDialog.Ok

        }

    }
}