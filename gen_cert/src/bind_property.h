#ifndef __BINDPROPERTY_H
#define __BINDPROPERTY_H

#include <QObject>
#include <QtQml>
#include <QString>

class BindProperty : public QObject {
    Q_OBJECT 
    QML_ELEMENT
    Q_PROPERTY(QString myProperty READ myProperty WRITE setMyProperty NOTIFY myPropertyChanged)
public:
    Q_INVOKABLE void testBindProperty(QString param);

    explicit BindProperty(QObject* parent = nullptr);
    QString myProperty() const;

    void setMyProperty(const QString& value); signals:

    void mySignal(QString message);

    void myPropertyChanged();
private:
    QString m_myProperty; 
};

#endif // __BINDPROPERTY_H