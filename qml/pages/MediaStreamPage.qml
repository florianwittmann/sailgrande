
import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../Api.js" as API
import "../Helper.js" as Helper
import "../components"
import "../MediaStreamMode.js" as MediaStreamMode
import "../Storage.js" as Storage
import "../CoverMode.js" as CoverMode
import "../FavManager.js" as FavManager

Page {
    id: page

    allowedOrientations:  Orientation.All

    property var nextMediaUrl: null
    property bool dataLoaded: false

    property int mode

    property string streamTitle
    property bool errorOccurred: false
    property var streamData: null
    property bool refreshStreamData : true
    property string tag: ""

    SilicaListView {
        id: listView
        model: mediaModel
        anchors.fill: parent
        header: PageHeader {
            title: streamTitle
        }
        delegate: FeedItem {
            visible: dataLoaded
            item: model
        }

        VerticalScrollDecorator {
            id: scroll
        }

        PullDownMenu {

            MenuItem {
                visible: mode === MediaStreamMode.TAG_MODE && tag !== ""
                text: qsTr("Pin this tag feed")
                onClicked: {
                    FavManager.addFavTag(tag)
                    saveFavTags()
                    console.log("current fav: " + FavManager.favTag)
                    if(FavManager.favTag==="")  {
                        FavManager.favTag = tag
                        console.log("favnow " + FavManager.favTag)
                        Storage.set("favtag", tag)
                    }
                }
            }

            MenuItem {
                text: qsTr("Refresh")
                onClicked: getMediaData(false)
            }
        }

        PushUpMenu {
            visible: nextMediaUrl !== null
            MenuItem {
                text: qsTr("Load more")
                onClicked: timerLoadmore.restart()
            }
        }
    }

    Timer {
        id: timerLoadmore
        interval: 500
        running: false
        repeat: false
        onTriggered: getNextMediaData()
    }

    ListModel {
        id: mediaModel
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: dataLoaded == false
        size: BusyIndicatorSize.Large
    }

    ErrorMessageLabel {
        visible: errorOccurred
    }

    ErrorMessageLabel {
        visible: dataLoaded && !errorOccurred && mediaModel.count === 0
        text: qsTr("There is no picture in this feed.")
    }

    Component.onCompleted: {
        if (streamData !== null) {
            mediaDataFinished(streamData)
            setCoverRefresh(CoverMode.SHOW_FEED, streamData,mode,tag)
        } else {
            getMediaData(true)
            getFeed(mode, tag, true, function (data) {
                setCoverRefresh(CoverMode.SHOW_FEED, data, mode,tag)
            })
        }
    }

    function mediaStreamPageRefreshCB() {
        listView.positionViewAtBeginning()
        getMediaData(true)
    }

    function getMediaData(cached) {
        dataLoaded = false
        mediaModel.clear()
        refreshStreamData = true
        getFeed(mode, tag, cached, mediaDataFinished)
    }

    function getNextMediaData() {
        refreshStreamData = false
        API.get_Url(nextMediaUrl, mediaDataFinished)
    }

    function mediaDataFinished(data) {
        if (data === undefined || data.items === undefined) {
            dataLoaded = true
            errorOccurred = true
            return
        }
        if(refreshStreamData) {
            streamData=data
            setCoverRefresh(CoverMode.SHOW_FEED, data, mode,tag)
        }

        errorOccurred = false

        for (var i = 0; i < data.items.length; i++) {
            mediaModel.append(data.items[i])
        }

        if(mediaModel.count>0) {

            var url = mediaModel.get(0).image_versions2.candidates[mediaModel.get(0).image_versions2.candidates.length-1].url
            var username = mediaModel.get(0).user.username
            setCoverImage(url, username)
        }

        if (data.pagination !== undefined && data.pagination.next_url) {
            nextMediaUrl = data.pagination.next_url
        } else {
            nextMediaUrl = null
        }
        dataLoaded = true
    }


    onStatusChanged: {
        if (status === PageStatus.Active) {
            refreshCallback = mediaStreamPageRefreshCB
            setCoverRefresh(CoverMode.SHOW_FEED, streamData, mode,tag)
        }
    }

}
