import QtQuick 2.0
import Sailfish.Silica 1.0


BackgroundItem {

    property var item;

            id: delegate
            height: image.height + 70
            width: parent.width

            Image {
                id: image
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium

                 anchors.top:  parent.top
                 anchors.topMargin: Theme.paddingSmall
                 height: image.width
                 source: item.images ? item.images.low_resolution.url : ""

                 Image {
                    anchors.centerIn: parent
                    source:  "image://theme/icon-cover-play"
                    visible: item.videos !== undefined
                 }
             }

            Label {
                id: label
                text: item.user.username +  " - " + Qt.formatDateTime(new Date(parseInt(item.created_time)*1000), "dd.MM.yy hh:mm")
                anchors.left:  parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.paddingSmall

                wrapMode: Text.Wrap
                anchors.top: image.bottom
                anchors.topMargin: Theme.paddingSmall
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
            }

    onClicked: {
        pageStack.push(Qt.resolvedUrl("../pages/MediaDetailPage.qml"),{item:item});
    }


        }
