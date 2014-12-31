import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import "../components"
import "../Api.js" as API
import "../CoverMode.js" as CoverMode
import "../Storage.js" as Storage

Page {

    property var item
    property bool playVideo : false
    property bool userLikedThis : false
    property bool likeStatusLoaded : false

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + header.height + 10
        contentWidth: parent.width

        PageHeader {
            id: header
            title: qsTr("Details")
        }

        Column {

            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            id: column
            spacing: Theme.paddingSmall

            UserInfoBlock {
                id:userInfo
            }

            Video {
                id: video
                anchors.left: parent.left
                anchors.right: parent.right
                height: visible ? video.width : 0
                visible: playVideo && video.status !== MediaPlayer.Loading
                source: ""

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        video.stop();
                    }
                }

                onStopped: {
                    playVideo = false;
                }
            }

            Rectangle {
                id: image
                anchors.left: parent.left
                anchors.right: parent.right
                height: image.width
                visible: !playVideo || video.status === MediaPlayer.Loading
                color: "transparent"

                Image {
                   anchors.fill: parent
                   source: item.images ? item.images.thumbnail.url : ""
                }

                Image {
                   anchors.fill: parent
                   source: item.images ? item.images.standard_resolution.url : ""
                }



                BusyIndicator {
                    anchors.centerIn: parent
                    visible: playVideo && video.status === MediaPlayer.Loading
                    running: visible
                }


                Image {
                   anchors.centerIn: parent
                   source:  "image://theme/icon-cover-play"
                   visible: item.videos !== undefined && !playVideo
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {startVideo()}
                    visible: item.videos !== undefined && !playVideo

                }
            }

            Label {
                id: likesCommentsCount
                text: item.likes.count + " " +qsTr("likes") + " - " + item.comments.count + " " + qsTr("comments")  + (userLikedThis? " - " + qsTr("You liked this.") : "")
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeTiny
                color: userLikedThis? Theme.highlightColor : Theme.secondaryHighlightColor
                visible: likeStatusLoaded
            }

            Label {
                id: description
                visible: text!==""
                font.bold: true
                text: item.caption !== undefined ? item.caption.text : ""
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium

                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
            }



            Repeater {
                model: item.comments.data.length
                width: parent.width

                Item {
                    height: labelUser.height+labelComment.height
                    width: parent.width

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.highlightColor
                        opacity: mousearea.pressed ? 0.3 : 0
                    }

                    Label {
                        id: labelUser
                        text: getCommentByIndex(index).from.username + " - " + Qt.formatDateTime(
                                  new Date(parseInt(getCommentByIndex(index).created_time) * 1000),
                                  "dd.MM.yy hh:mm")
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingMedium
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingMedium

                        wrapMode: Text.Wrap
                        truncationMode: TruncationMode.Fade
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.secondaryHighlightColor
                    }
                    Label {
                        id: labelComment
                        text: getCommentByIndex(index).text
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingMedium
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingMedium
                        anchors.top: labelUser.bottom
                        wrapMode: Text.Wrap
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }


                    MouseArea {
                        id: mousearea
                        anchors.fill: parent
                        onClicked: {
                            if(playVideo)
                                video.stop();
                            pageStack.push(Qt.resolvedUrl("../pages/UserProfilPage.qml"),{user:getCommentByIndex(index).from});
                        }
                    }
                }
            }

           /* TextField {
                id: postComment
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                placeholderText: qsTr("Tap here to add a comment", "Message composing tet area placeholder")
                textRightMargin:  64
                background: Component {
                    Item {
                        anchors.fill: parent

                        IconButton {
                            id: sendButton
                            icon.source: "image://theme/icon-m-message"
                            highlighted: enabled
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: - Theme.paddingSmall
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.paddingSmall
                            onClicked: {
                                API.post_Comment(item.id, postComment.text)
                            }
                        }
                    }
                }
            }
        }*/}


        PullDownMenu {
            visible: likeStatusLoaded

            MenuItem {
                 text: qsTr("Remove my like")
                 visible: userLikedThis && likeStatusLoaded
                 onClicked: {
                     item.user_has_liked= false;
                     API.unlike(item.id, reload);
                 }
             }

            MenuItem {
                 text: qsTr("Like")
                 visible: !userLikedThis && likeStatusLoaded
                 onClicked: {
                     item.user_has_liked= true;
                     API.like(item.id, reload);
                 }
             }



           }

    }

    function getCommentByIndex(index) {
        return item.comments.data[index]
    }

    function startVideo() {
        video.source=item.videos.low_bandwidth.url;
        video.play();
        playVideo=true;
    }

    Component.onCompleted: {
        var coverdata = {}
        coverdata.image = item.images.thumbnail.url;
        coverdata.username = item.user.username;

        setCover(CoverMode.SHOW_IMAGE,coverdata)

        userLikedThis = item.user_has_liked;
        reload();

        refreshCallback = null

    }

    function reload() {
        API.get_MediaById(item.id,reloadFinished);
    }

    function reloadFinished(data) {
        likeStatusLoaded = true;
        userLikedThis = data.data.user_has_liked;
    }


}
