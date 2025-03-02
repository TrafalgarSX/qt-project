#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "LogModel.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Register the LogModel as a QML type
    qmlRegisterType<LogModel>("LogViewer", 1, 0, "LogModel");

    const QUrl url(QStringLiteral("qrc:/qt/qml/gen_cert/ui/Main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
