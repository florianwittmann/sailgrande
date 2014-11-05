import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Api.js" as API


CoverBackground {


    property bool active: status == Cover.Active

    property var image : null;

    onActiveChanged : setImage()

    function setImage() {
        image =  API.coverImage;
    }


    Column {
        visible: image===null

        anchors.centerIn: parent
        width:  parent.width
        spacing: Theme.paddingMedium

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "/usr/share/icons/hicolor/86x86/apps/harbour-sailgrande.png"
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "SailGrande"
        }
    }

    Image {
        id: coverImg
        anchors.top: Theme.paddingMedium
        width: parent.width
        height: width
        source: image!==null ? image.images.thumbnail.url : ""
        visible: source !== ""
    }

    Label {
        id: label
        text: image!==null? image.user.username : ""
        visible: text!==""
        anchors.left:  parent.left
        anchors.leftMargin: Theme.paddingSmall
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingSmall

        anchors.top: coverImg.bottom
        anchors.topMargin: Theme.paddingSmall
        truncationMode: TruncationMode.Fade
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.secondaryHighlightColor
    }


}


