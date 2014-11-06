import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "pages"
import "Storage.js" as Storage
import "Api.js" as API

ApplicationWindow
{
    initialPage: getInitialPage()
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    function getInitialPage() {
        var token = Storage.get("authtoken","");
        if(token === "") {
            return Qt.resolvedUrl("pages/AuthPage.qml")
        } else {
            API.access_token = token;
            return Qt.resolvedUrl(Qt.resolvedUrl("pages/StartPage.qml"))

        }

    }


}


