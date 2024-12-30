#ifndef __GEN_CERT_H
#define __GEN_CERT_H

#include <QObject>
#include <QString>

class GenCertHelper : public QObject
{
    Q_OBJECT
public:
    explicit GenCertHelper(QObject *parent = nullptr);

    Q_INVOKABLE bool genCert(QString pubkey_hex, QString cert_file_path);

signals:

public slots:
};

#endif // __GEN_CERT_H
