import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import QtQuick.LocalStorage 2.0

import "../components"
import "../Api.js" as API
import "../Helper.js" as Helper
import "../MediaStreamMode.js" as MediaStreamMode
import "../Storage.js" as Storage
import "../CoverMode.js" as CoverMode


Page {

    id: startPage
    property var user
    property bool relationStatusLoaded: false
    property bool recentMediaLoaded: false
    property bool updateRunning: false

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            updateAllFeeds()
        }
    }

    function updateAllFeeds() {
        if (updateRunning)
            return

        console.log("update...")
        updateRunning = true
        myFeedBlock.refreshContent(refreshMyFeedBlockFinished)
    }

    function refreshMyFeedBlockFinished() {
        getFeed(MediaStreamMode.MY_STREAM_MODE,"",true,function(data) {
            setCover(CoverMode.SHOW_FEED,data)
        })
        refreshPopularFeedBlock()
    }

    function refreshPopularFeedBlock() {
        if(!startPageShowPopularFeed) {
            refreshFavoriteTagFeedBlock()
            return;
        }

        popularFeedBlock.refreshContent(refreshPopularFeedBlockFinished)
    }

    function refreshPopularFeedBlockFinished() {
        refreshFavoriteTagFeedBlock()
    }

    function refreshFavoriteTagFeedBlock() {
        favoriteTagFeedBlock.refreshContent(refreshDone)
    }

    function refreshDone() {
        updateRunning = false
        console.log("RefreshDone")
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + header.height + 10
        contentWidth: parent.width

        PageHeader {
            id: header
            title: qsTr("Welcome")
            description: user !== undefined ? user.username : ""
        }

        Column {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            id: column

            Rectangle {
                height: 150
                width: parent.width
                color: "transparent"

                Rectangle {
                    anchors.fill: parent
                    color: Theme.highlightColor
                    opacity: mouseAreaMyProfile.pressed ? 0.3 : 0.1
                }

                UserDetailBlock {
                    id: userDetailBlock
                }

                MouseArea {
                    anchors.fill: parent
                    id: mouseAreaMyProfile
                    onClicked: pageStack.push(Qt.resolvedUrl(
                                                  "UserProfilPage.qml"), {
                                                  user: user
                                              })
                }
            }

            StreamPreviewBlock {
                id: myFeedBlock

                streamTitle: qsTr('My Feed')
                mode: MediaStreamMode.MY_STREAM_MODE
            }

            StreamPreviewBlock {
                visible: startPageShowPopularFeed
                id: popularFeedBlock
                streamTitle: qsTr('Popular')
                mode: MediaStreamMode.POPULAR_MODE
            }

            StreamPreviewBlock {
                id: favoriteTagFeedBlock

                property string favoriteTag: loadFavoriteTag()
                visible: favoriteTag !== ""
                streamTitle: qsTr('Tagged with %1').arg(favoriteTag)
                mode: MediaStreamMode.TAG_MODE
                tag: favoriteTag

                function loadFavoriteTag() {
                    return Storage.get("favtag", "")
                }
            }
        }

        PullDownMenu {

            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }


            MenuItem {
                text: qsTr("Search")
                onClicked: pageStack.push(Qt.resolvedUrl("TagSearchPage.qml"))
            }

            MenuItem {
                 text: qsTr("Refresh")
                 onClicked: updateAllFeeds()
             }
        }
    }

    ListModel {
        id: recentMediaModel
    }

    Component.onCompleted: {
        loadProfilePreview()
    }

    function loadProfilePreview() {
        API.get_UserById('self', loadProfilePreviewFinished)
    }

    function loadProfilePreviewFinished(data) {
        if (data.meta.code === 200) {
            user = data.data
            API.selfId = user.id
        }
    }

}
