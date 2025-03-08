#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "applicationsettings.h"
#include "SettingsManager.h"
#include "util/utils_screen.h"

const QString APP_VERSION = "0.1";

int main(int argc, char *argv[])
{
    QApplication::setOrganizationName("Trafalgar");
    QApplication::setApplicationName("logviewer");
    QApplication::setApplicationDisplayName("LogViewer");
    QApplication::setApplicationVersion(APP_VERSION);

    QApplication app(argc, argv);

    qRegisterMetaType<ApplicationSettings*>();

    ApplicationSettings settings;
    SettingsManager *sm = SettingsManager::getInstance();
    sm->setAppTheme("THEME_DESKTOP_LIGHT");
    UtilsScreen *utilsScreen = UtilsScreen::getInstance();

    QQmlApplicationEngine engine;
    QQmlContext *engine_context = engine.rootContext();
    engine_context->setContextProperty("settingsManager", sm);
    engine_context->setContextProperty("utilsScreen", utilsScreen);
    engine_context->setContextProperty("settings", &settings);

    const QUrl url(QStringLiteral("qrc:/qt/qml/Logviewer/ui/Main.qml"));
    engine.load(url);
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    return app.exec();
}
