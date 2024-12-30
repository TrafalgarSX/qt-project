#ifndef __FILEDIALOGHELPER_H
#define __FILEDIALOGHELPER_H

#include <QObject>
#include <QString>
class FileDialogHelper : public QObject
{
    Q_OBJECT
public:
    explicit FileDialogHelper(QObject *parent = nullptr);

    Q_INVOKABLE QString openFileDialog();

signals:

public slots:
};

#endif // __FILEDIALOGHELPER_H
