#include "emit_signal.h"
#include <QDebug>

EmitSingal::EmitSingal(QObject* parent) : QObject(parent) {}

void EmitSingal::testEmitSignal(QString param) {
    qDebug() << "testEmitSignal() called";
    qDebug() << param;
}