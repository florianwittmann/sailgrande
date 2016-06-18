import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    width: parent.width
    height:150
    anchors.right: parent.right



    Image {
        id: profilpic
       width:150
       height:150
       anchors.right: parent.right
       source: user.profile_pic_url
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: profilpic.left
        anchors.rightMargin: Theme.paddingMedium
        anchors.top: parent.top
        anchors.topMargin: 10

        Label {
            text: user !== undefined && user.media_count !== undefined ? qsTr("%1 posts").arg(user.media_count) :""
            anchors.left: parent.left
            anchors.right: parent.right
            color: Theme.secondaryColor
            visible: text!==""
            truncationMode: TruncationMode.Fade
        }


        Label {
            text: user !== undefined && user.follower_count !== undefined ? qsTr("%1 followers").arg(user.follower_count) : ""
            anchors.left: parent.left
            anchors.right: parent.right
            color: Theme.secondaryColor
            visible: text!==""
            truncationMode: TruncationMode.Fade

        }

        Label {
            text: user !== undefined && user.counts !== undefined ? qsTr("%1 following").arg(user.counts.follows) : ""
            anchors.left: parent.left
            anchors.right: parent.right
            color: Theme.secondaryColor
            visible: text!==""
            truncationMode: TruncationMode.Fade
        }
    }
}
