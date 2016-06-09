import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../Storage.js" as Storage
import "../Api.js" as API

Page {
    property bool logout: false

    Column {
        id: col
        spacing: 15
        visible: !loginArea.visible
        anchors.fill: parent
        PageHeader {
            title: "Prostogram"
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
            text: qsTr("Welcome to Prostogram, an unoffical Instagram client for Sailfish. Please press 'continue' to login to your Instagram account.")
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
                loginArea.visible = true
            }
        }
    }

    Rectangle{
        id: loginArea
        visible: false

        width: parent.width
        height: parent.height

        Image{
            id: backImage
            width: parent.width
            height: parent.height

            source: "../images/cover.jpg"

            fillMode: Image.PreserveAspectCrop

            clip: true
        }

        Rectangle{
            id: entherAction
            color: "white"
            clip: true
            radius: 5

            width: parent.width-0.25*parent.width
            height: Theme.itemSizeMedium*3

            anchors{
                bottom: parent.bottom
                bottomMargin: 0.125*parent.width
                left: parent.left
                leftMargin: 0.125*parent.width
            }

            TextField{
                id: loginField
                width: parent.width-10
                height: Theme.itemSizeMedium

                placeholderText: qsTr("Login")
                placeholderColor: "black"
                color: "black"

                anchors{
                    top: parent.top
                    left: parent.left
                    leftMargin: 5
                }
            }

            TextField{
                id: passwordField
                width: parent.width-10
                height: Theme.itemSizeMedium

                placeholderText: qsTr("Password")
                placeholderColor: "black"
                color: "black"

                echoMode: TextInput.Password

                anchors{
                    top: loginField.bottom
                    left: parent.left
                    leftMargin: 5
                }
            }

            Rectangle{
                id: loginButton
                width: parent.width
                height: Theme.itemSizeMedium
                radius: 5

                color: "#5caa15"

                anchors{
                    bottom: parent.bottom
                    left: parent.left
                }

                Text{
                    text: qsTr("Login")
                    color: "white"
                    width: parent.width
                    height: parent.height/3*2

                    fontSizeMode: Text.Fit
                    minimumPixelSize: 10
                    font.pixelSize: 72

                    anchors{
                        verticalCenter: parent.verticalCenter
                    }

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle{
                    color: parent.color
                    width: parent.radius
                    height: parent.radius
                    anchors{
                        top: parent.top
                        left: parent.left
                    }
                }

                Rectangle{
                    color: parent.color
                    width: parent.radius
                    height: parent.radius
                    anchors{
                        top: parent.top
                        right: parent.right
                    }
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if(loginField.text && passwordField.text)
                        {
                            instagram.setUsername(loginField.text);
                            instagram.setPassword(passwordField.text);
                            instagram.login(true);
                        }
                    }
                }
            }
        }
    }

    Connections{
        target: instagram
        onProfileConnected:{
            Storage.set("password", passwordField.text);
            Storage.set("username",loginField.text)
            pageStack.push(Qt.resolvedUrl("StartPage.qml"));
        }
    }

    Connections{
        target: instagram
        onProfileConnectedFail:{
            console.log(answer)
        }
    }
}
