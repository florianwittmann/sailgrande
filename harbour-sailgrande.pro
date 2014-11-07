# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-sailgrande

CONFIG += sailfishapp

SOURCES += src/harbour-sailgrande.cpp

OTHER_FILES += qml/harbour-sailgrande.qml \
    qml/cover/CoverPage.qml \
    qml/pages/SecondPage.qml \
    rpm/harbour-sailgrande.spec \
    rpm/harbour-sailgrande.yaml \
    translations/*.ts \
    harbour-sailgrande.desktop \
    qml/Api.js \
    qml/Helper.js \
    qml/Storage.js \
    qml/components/FeedItem.qml \
    qml/components/UserInfoBlock.qml \
    qml/harbour-sailgrande.qml \
    LICENSE \
    Changelog \
    qml/pages/AuthPage.qml \
    qml/pages/MediaDetailPage.qml \
    qml/pages/UserProfilPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/MediaStreamPage.qml \
    qml/MediaStreamMode.js \
    qml/pages/StartPage.qml \
    qml/components/UserDetailBlock.qml \
    qml/components/StreamPreviewBlock.qml \
    qml/pages/TagSearchPage.qml \
    qml/components/SmallMediaElement.qml \
    qml/components/ErrorMessageLabel.qml \
    qml/pages/SettingsPage.qml \
    qml/CoverMode.js \
    qml/Cover.js \
    qml/FavManager.js \
    qml/pages/PinnedPage.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-sailgrande-en.ts
