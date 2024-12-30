#include <file_dialog_helper.h>

#include <QFileDialog>


FileDialogHelper::FileDialogHelper(QObject* parent) : QObject(parent) {}

QString FileDialogHelper::openFileDialog()
{
    QString filePath = QFileDialog::getExistingDirectory(nullptr, "选择保存路径", "");
    return filePath;
}