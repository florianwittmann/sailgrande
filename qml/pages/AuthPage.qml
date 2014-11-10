import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../Storage.js" as Storage
import "../Api.js" as API

Page {

    property string client_id: "b1c42c7d03924317a19c5dc603c727e3"
    property string redirect_uri: "http://localhost:3850/Home/Auth"

    property string auth_url: "https://instagram.com/oauth/authorize/?client_id=" + client_id
                              + "&scope=likes+comments+relationships&redirect_uri="
                              + redirect_uri + "&response_type=token"
    property string logout_url: "https://instagram.com/accounts/logout"
    property string loggedOut_url: "http://instagram.com/"

    property bool showWebview: false

    property bool logout: false

    Column {
        id: col
        spacing: 15
        visible: !showWebview
        anchors.fill: parent
        PageHeader {
            title: "SailGrande"
        }
        Image {
            source: "../images/header_logo.png"
        }

        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter

            visible: logout
            running: logout
            size: BusyIndicatorSize.Large
        }

        Label {
            visible: !logout
            text: qsTr("Welcome to SailGrande, an unoffical Instagram client for Sailfish. Please press 'continue' to login to your Instagram account.")
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingLarge
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            wrapMode: Text.Wrap
            textFormat: Text.RichText
            color: Theme.highlightColor
        }
        Button {
            visible: !logout
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Continue")
            onClicked: {
                webview.url = auth_url
                webview.visible = true
                showWebview = true
            }
        }
    }

    SilicaWebView {
        id: webview
        visible: showWebview
        anchors.fill: parent
        onUrlChanged: {
            console.log("Auth: " + url)
            if (url.toString() === "")
                return

            if (url.toString().indexOf(redirect_uri) == 0) {
                //Success
                console.log(url)
                var extracted = url.toString().substring(
                            redirect_uri.length + 14)
                var posExpire = extracted.indexOf("&expires=")
                if (posExpire != -1) {
                    extracted = extracted.slice(0, posExpire)
                }
                API.access_token = extracted

                authentificated()
            } else {

            }

        }
    }

    SilicaWebView {
        id: logOutWebview
        visible: false
        onUrlChanged: {
           console.log("Logout: " + url)
            if (url.toString() === "")
                return
            if (logout) {
                if (url.toString() === loggedOut_url) {
                    logout = false
                }
            }
        }
    }

    function authentificated() {
        Storage.set("authtoken", API.access_token)
        pageStack.replace(Qt.resolvedUrl("StartPage.qml"))
    }

    Component.onCompleted: {
        if (logout) {
            logOutWebview.url = logout_url
        }
    }
}
