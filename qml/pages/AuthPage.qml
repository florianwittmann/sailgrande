import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../Storage.js" as Storage
import "../Api.js" as API

Page {

    property string client_id: "b1c42c7d03924317a19c5dc603c727e3"
    property string redirect_uri : "http://localhost:3850/Home/Auth"

    property string auth_url : "https://instagram.com/oauth/authorize/?client_id=" + client_id + "&scope=likes+comments+relationships&redirect_uri=" + redirect_uri + "&response_type=token"
    property bool showWebview : false

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

        Label {
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
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Continue")
            onClicked : {
                webview.url = auth_url;
                webview.visible = true;
                showWebview = true;
            }
        }
    }

    SilicaWebView {
        id: webview
        visible: showWebview

        anchors.fill: parent

        onUrlChanged: {
            if(url.toString().indexOf(redirect_uri)==0) {
                //Success
                console.log(url);
                var extracted = url.toString().substring(redirect_uri.length + 14);
                var posExpire = extracted.indexOf("&expires=");
                if(posExpire != -1) {
                    extracted = extracted.slice(0,posExpire)
                }
                API.access_token = extracted

                authentificated();

            } else {
                console.log(url);
            }
        }

    }

    function authentificated() {
        Storage.set("authtoken",API.access_token);
        pageStack.replace(Qt.resolvedUrl("MediaStreamPage.qml"));
    }

}
