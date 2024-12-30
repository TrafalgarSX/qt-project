#include <file_dialog_helper.h>
#include <gen_cert.h>

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>


int main(int argc, char* argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    FileDialogHelper fileDialogHelper;
    engine.rootContext()->setContextProperty("fileDialogHelper", &fileDialogHelper);
    GenCertHelper genCertHelper;
    engine.rootContext()->setContextProperty("genCertHelper", &genCertHelper);

    const QUrl url(QStringLiteral("qrc:/qt/qml/gen_cert/ui/gen_cert.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
