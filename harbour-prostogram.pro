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
TARGET = harbour-prostogram

i18n_files.files = translations
i18n_files.path = /usr/share/$$TARGET

INSTALLS += i18n_files

CONFIG += sailfishapp

SOURCES += src/harbour-prostogram.cpp \
    src/api/instagramrequest.cpp \
    src/api/instagram.cpp \
    src/cripto/hmacsha.cpp

OTHER_FILES += qml/harbour-prostogram.qml \
    qml/cover/CoverPage.qml \
    qml/pages/SecondPage.qml \
    rpm/harbour-prostogram.spec \
    rpm/harbour-prostogram.yaml \
    translations/* \
    harbour-prostogram.desktop \
    qml/Api.js \
    qml/Helper.js \
    qml/Storage.js \
    qml/components/FeedItem.qml \
    qml/components/UserInfoBlock.qml \
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
    qml/pages/PinnedPage.qml \
    qml/pages/UserListPage.qml \
    qml/components/UserListItem.qml \
    qml/UserListMode.js

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

HEADERS += \
    src/api/instagram.h \
    src/api/instagramrequest.h \
    src/cripto/hmacsha.h

DISTFILES += \
    qml/harbour-prostogram.qml
