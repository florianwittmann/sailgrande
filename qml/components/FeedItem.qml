import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {

    property var item

    id: delegate
    height: feedItemCol.height
    width: parent.width

    Column {
        id: feedItemCol
        width: parent.width

        Image {
            id: image
            anchors.left: parent.left
            anchors.right: parent.right
            height: image.width
            source: item.images ? item.images.low_resolution.url : ""

            Image {
                anchors.centerIn: parent
                source: "image://theme/icon-cover-play"
                visible: item.videos !== undefined
            }

            Item {
                visible: feedsShowUserDate && feedsShowUserDateInline

                height: labelInline.height+Theme.paddingSmall*2
                anchors.bottom: image.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                Rectangle {
                    color: "black"
                    opacity: 0.5
                    anchors.fill: parent
                }

                Label {
                    id: labelInline
                    text: item.user.username + " - " + Qt.formatDateTime(
                              new Date(parseInt(item.created_time) * 1000),
                              "dd.MM.yy hh:mm")
                    anchors.centerIn: parent
                    wrapMode: Text.Wrap

                    truncationMode: TruncationMode.Fade
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                }
            }

        }

        Label {
            text: item.user.username + " - " + Qt.formatDateTime(
                      new Date(parseInt(item.created_time) * 1000),
                      "dd.MM.yy hh:mm")
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingMedium
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            wrapMode: Text.Wrap

            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryHighlightColor
            visible: feedsShowUserDate && !feedsShowUserDateInline
        }

        Label {
            id: description
            visible: feedsShowCaptions && text !== ""
            text: item.caption !== undefined ? item.caption.text : ""
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingMedium
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium

            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.highlightColor
        }
        Item {
            width: parent.width
            height: Theme.paddingLarge
            visible: (feedsShowUserDate && !feedsShowUserDateInline) || feedsShowCaptions
        }
    }

    onClicked: {
        pageStack.push(Qt.resolvedUrl("../pages/MediaDetailPage.qml"), {
                           item: item
                       })
    }
}
