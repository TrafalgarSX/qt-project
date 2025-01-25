#ifndef __EMITSIGNAL_H
#define __EMITSIGNAL_H


#include <QObject>
#include <QString>

class EmitSingal : public QObject {
    Q_OBJECT 
public:

    explicit EmitSingal(QObject* parent = nullptr);

public slots:
    void testEmitSignal(QString param);
private:
    QString m_myProperty; 
};



#endif // __EMITSIGNAL_H