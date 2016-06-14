
import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../Helper.js" as Helper
import "../components"
import "../MediaStreamMode.js" as MediaStreamMode
import "../Storage.js" as Storage
import "../CoverMode.js" as CoverMode
import "../FavManager.js" as FavManager

Page {
    id: page

    allowedOrientations:  Orientation.All
    property bool dataLoaded: false

    property int mode

    property string streamTitle
    property bool errorOccurred: false
    property var streamData: null
    property bool refreshStreamData : true
    property string tag: ""

    property bool more_available
    property string next_max_id

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
                onClicked: {
                    dataLoaded = false
                    mediaModel.clear()
                    getMedia();
                }
            }
        }

        PushUpMenu {
            visible: more_available
            MenuItem {
                text: qsTr("Load more")
                onClicked: {
                    getMedia(next_max_id)
                }
            }
        }
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
        getMedia();
    }

    function getMedia(next_id)
    {
        if(page.mode === 0)
        {
            instagram.getTimeLine(next_id);
        }
        else if(page.mode === 1)
        {
            instagram.getPopularFeed(next_id)
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

    function mediaDataFinished(data) {
        streamData = data;
        if(data ===null || data === undefined || data.items.length === 0)
        {
            dataLoaded=true;
            errorOccurred=true
            return;
        }
        errorOccurred = false

        for(var i=0; i<data.items.length; i++) {
            mediaModel.append(data.items[i]);
        }

        dataLoaded = true

        page.more_available = data.more_available
        if(page.more_available)
        {
            page.next_max_id = data.next_max_id
        }
        else
        {
            page.next_max_id = "";
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            refreshCallback = mediaStreamPageRefreshCB
            setCoverRefresh(CoverMode.SHOW_FEED, streamData, mode,tag)
        }
    }

    Connections{
        target: instagram
        onTimeLineDataReady: {
            console.log(answer)
            var data = JSON.parse(answer);
            if(page.mode === 0)
            {
                mediaDataFinished(data);
            }
        }
    }

    Connections{
        target: instagram
        onPopularFeedDataReady: {
            var data = JSON.parse(answer);
            if(page.mode === 1)
            {
                mediaDataFinished(data);
            }
        }
    }
}
