#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QtGui/QGuiApplication>
#include <QQmlContext>
#include <QQuickView>
#include <QTranslator>

int main(int argc, char *argv[])
{
   QGuiApplication* app = SailfishApp::application(argc, argv);
   QString translationPath(SailfishApp::pathTo("translations").toLocalFile());

   QTranslator engineeringEnglish;
   engineeringEnglish.load("sailgrande", translationPath);
   qApp->installTranslator(&engineeringEnglish);

   QTranslator translator;
   translator.load(QLocale(), "sailgrande", "_", translationPath);
   qApp->installTranslator(&translator);

   QScopedPointer <QQuickView> view(SailfishApp::createView());
   app->setApplicationName("harbour-sailgrande");
   app->setOrganizationDomain("harbour-sailgrande");
   app->setOrganizationName("harbour-sailgrande");

   view->setTitle("SailGrande");


   QUrl pageSource = SailfishApp::pathTo("qml/harbour-sailgrande.qml");
   view->setSource(pageSource);


   view->showFullScreen();

   return app->exec();
}

