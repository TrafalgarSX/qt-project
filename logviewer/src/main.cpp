#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "SettingsManager.h"
#include "util/utils_screen.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    SettingsManager *sm = SettingsManager::getInstance();
    sm->setAppTheme("THEME_DESKTOP_LIGHT");
    UtilsScreen *utilsScreen = UtilsScreen::getInstance();

    QQmlApplicationEngine engine;
    QQmlContext *engine_context = engine.rootContext();
    engine_context->setContextProperty("settingsManager", sm);
    engine_context->setContextProperty("utilsScreen", utilsScreen);

    const QUrl url(QStringLiteral("qrc:/qt/qml/Logviewer/ui/Main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
