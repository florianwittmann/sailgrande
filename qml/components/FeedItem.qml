import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {

    property var item

    id: delegate
    height: feedItemCol.height
    width: parent.width
    property bool landscapeMode : (orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted)

    Item {

        anchors.fill: parent

        Column {
            id: feedItemCol
            width: (landscapeMode) ?  parent.width* 0.4 : parent.width
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
                    visible: feedsShowUserDate && feedsShowUserDateInline &&  !landscapeMode

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

                id: userDateLine
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
                visible: feedsShowUserDate && !feedsShowUserDateInline && !landscapeMode

            }

            Label {

                id: description
                visible: feedsShowCaptions && text !== "" && !landscapeMode
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
                id: paddingItem
                width: parent.width
                height: Theme.paddingLarge
                visible: userDateLine.visible || description.visible
            }
        }


        Item {
            visible: landscapeMode
            anchors.left: feedItemCol.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Label {
                id: userInfoLandscape
                visible: landscapeMode
                text: item.user.username + " - " + Qt.formatDateTime(
                          new Date(parseInt(item.created_time) * 1000),
                          "dd.MM.yy hh:mm")
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                wrapMode: Text.Wrap

                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
            }

            Label {
                clip: true
                anchors.top: userInfoLandscape.bottom
                anchors.bottom: parent.bottom
                id: descriptionSide
                visible: text !== ""
                text: (item.caption !== undefined && landscapeMode) ? item.caption.text : ""
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium

                truncationMode: TruncationMode.Elide
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
            }
        }
    }




    onClicked: {
        pageStack.push(Qt.resolvedUrl("../pages/MediaDetailPage.qml"), {
                           item: item
                       })
    }
}
