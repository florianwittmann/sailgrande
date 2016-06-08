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
import "../Cover.js" as CoverCtl
import "../FavManager.js" as FavManager


Page {


    allowedOrientations:  Orientation.All
    id: startPage
    property var user
    property bool relationStatusLoaded: false
    property bool recentMediaLoaded: false
    property bool updateRunning: false
    property string favoriteTag: ""

    onStatusChanged: {
        if (status === PageStatus.Active) {
            refreshCallback = startPageRefreshCB
            updateAllFeeds()
        }
    }

    function updateAllFeeds() {
        if (updateRunning) {
            return
        }

        console.log("update...")
        updateRunning = true
        myFeedBlock.refreshContent(refreshMyFeedBlockFinished)
    }

    function refreshMyFeedBlockFinished() {
        getFeed(MediaStreamMode.MY_STREAM_MODE, "", true, function (data) {
            setCoverRefresh(CoverMode.SHOW_FEED, data,MediaStreamMode.MY_STREAM_MODE,"")
        })

        refreshPopularFeedBlock()
    }

    function refreshPopularFeedBlock() {
        if (!startPageShowPopularFeed) {
            refreshFavoriteTagFeedBlock()
            return
        }

        popularFeedBlock.refreshContent(refreshPopularFeedBlockFinished)
    }

    function refreshPopularFeedBlockFinished() {
        refreshFavoriteTagFeedBlock()
    }

    function refreshFavoriteTagFeedBlock() {

        if(FavManager.favTag===null) FavManager.favTag = ""

        console.log("current fav " + favoriteTag + " - new " + FavManager.favTag)
        if(favoriteTag!==FavManager.favTag) {
            favoriteTag = FavManager.favTag
        }

        favoriteTagFeedBlock.refreshContent(refreshDone)
    }

    function refreshDone() {
        updateRunning = false
        console.log("RefreshDone")
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + header.height
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

                visible: favoriteTag !== ""
                streamTitle: qsTr('Tagged with %1').arg(favoriteTag)
                mode: MediaStreamMode.TAG_MODE
                tag: favoriteTag


            }



            Item {
                id:allPinnedTags
                visible: favoriteTag !== ""

                height: Theme.itemSizeMedium
                width: parent.width


                Rectangle {
                    anchors.fill: parent
                    color: Theme.highlightColor
                    opacity : mouseAreaAllPinnedTags.pressed ? 0.3 : 0
                }

                Image {
                    id: icon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    source:  "image://theme/icon-m-right"
                }

                Label {
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.primaryColor
                    text:qsTr("All pinned tags")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: icon.left
                    anchors.rightMargin: Theme.paddingMedium
                }

                MouseArea {
                    id: mouseAreaAllPinnedTags
                    anchors.fill: parent
                    onClicked: pageStack.push(Qt.resolvedUrl("PinnedPage.qml"))
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

    }

    function startPageRefreshCB() {

        if (updateRunning) {
            return
        }
        console.log("update...")
        updateRunning = true
        myFeedBlock.refreshContent(refreshDone)
    }

    Connections{
        target: instagram
        onProfileConnected:{
            var username_id = instagram.getUsernameId();
            instagram.getUsernameInfo(username_id)

            console.log("PROFILE"+answer)
        }
    }

    Connections{
        target: instagram
        onUsernameDataReady: {
            var obj = JSON.parse(answer)
            user = obj.user
        }
    }

    Connections{
        target: instagram
        onProfileConnectedFail:{
            app.cover = Qt.resolvedUrl("AuthPage.qml")
        }
    }
}
