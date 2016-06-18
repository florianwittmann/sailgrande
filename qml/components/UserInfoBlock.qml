import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: userInfo

    anchors.right: parent.right
    height: 100
    width: parent.width
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Theme.highlightColor
        opacity: mousearea.pressed ? 0.3 : 0.1
    }

    Image {
        id: profilpicture
        anchors.right: userInfo.right

        anchors.top: userInfo.top
        height: userInfo.height
        width: height
        source: item.user.profile_pic_url
    }

    Label {
        id:username
        text: item.user.username
        anchors.right: profilpicture.left
        anchors.rightMargin: Theme.paddingMedium
        anchors.top: userInfo.top
        anchors.topMargin: 15
        truncationMode: TruncationMode.Fade
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.secondaryHighlightColor
    }

    Label {
        text: Qt.formatDateTime(
                  new Date(parseInt(item.created_time) * 1000),
                  "dd.MM.yy hh:mm")
        anchors.right: profilpicture.left
        anchors.rightMargin: Theme.paddingMedium
        anchors.top: username.bottom

        truncationMode: TruncationMode.Fade
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.secondaryHighlightColor
    }

    MouseArea {
        id: mousearea
        anchors.fill: parent
        onClicked: {
            if(playVideo)
                video.stop();
            pageStack.push(Qt.resolvedUrl("../pages/UserProfilPage.qml"),{user:item.user});
        }
    }
}
