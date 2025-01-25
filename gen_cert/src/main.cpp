#include <file_dialog_helper.h>
#include <gen_cert.h>
#include <bind_property.h>
#include <emit_signal.h>

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
#if 1
    EmitSingal emitSignal;
    engine.rootContext()->setContextProperty("emitSignalObj", &emitSignal);
#endif

    // qmlRegisterType<BindProperty>("com.mycompany", 1, 0, "BindProperty");

    // const QUrl url(QStringLiteral("qrc:/qt/qml/gen_cert/ui/gen_cert.qml"));
    const QUrl url(QStringLiteral("qrc:/qt/qml/gen_cert/ui/Test.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app, [&app, &url, &engine](QObject* obj, const QUrl& objUrl) {
        if (!obj && url == objUrl) {
            QCoreApplication::exit(-1);
        }else{
            if(engine.rootObjects().isEmpty()){
                return;
            }

            QObject *rootObject = engine.rootObjects().first();
            // 调用 QML 中的函数
            QMetaObject::invokeMethod(rootObject, "qmlFunction",
                                    Q_ARG(QVariant, "Hello from C++"));
        }
    }, Qt::QueuedConnection);

    return app.exec();
}
