#include "bind_property.h"
#include <QDebug>

// https://blog.csdn.net/qq_21438461/article/details/125726533
BindProperty::BindProperty(QObject* parent)
    : QObject(parent) // 提供默认值
{
}

QString BindProperty::myProperty() const {
    qDebug() << "myProperty() called";
    return m_myProperty;
}

void BindProperty::setMyProperty(const QString& value) {
    qDebug() << "setMyProperty() called";
    if (m_myProperty != value) {
        m_myProperty = value;
        emit myPropertyChanged();
    }
}

void BindProperty::testBindProperty(QString param) {
    qDebug() << "testBindProperty() called";
    // 实现函数逻辑
    m_myProperty = param;
    emit myPropertyChanged();
}