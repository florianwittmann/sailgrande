import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../Api.js" as API
import "../Helper.js" as Helper
import "../components"
import "../MediaStreamMode.js" as MediaStreamMode
import "../Storage.js" as Storage


Page {
    id: page

    property var nextMediaUrl :null
    property bool dataLoaded: false

    property int mode

    property string streamTitle

    property var streamData : null
    property string tag : ""



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

        VerticalScrollDecorator {}

        PullDownMenu {


            MenuItem {
                 visible: mode === MediaStreamMode.TAG_MODE && tag !== ""
                 text: qsTr("Pin this tag feed")
                 onClicked: {
                     Storage.set("favtag",tag);
                     pageStack.replaceAbove(null,Qt.resolvedUrl("StartPage.qml"));

                 }

             }

            MenuItem {
                 text: qsTr("Refresh")
                 onClicked: getMediaData()
             }

           }

        PushUpMenu {
            visible: nextMediaUrl !== null;
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

    Component.onCompleted: {
        if(streamData!==null) {
            mediaDataFinished(streamData);
        } else {
            getMediaData();
        }
     }


    function getMediaData() {
        dataLoaded=false;
        mediaModel.clear();
        if(mode=== MediaStreamMode.MY_STREAM_MODE) {
            API.get_UserFeed(mediaDataFinished);
        } else if(mode === MediaStreamMode.POPULAR_MODE) {
            API.get_Popular(mediaDataFinished);
        } else if(mode === MediaStreamMode.TAG_MODE && tag !== "") {
            API.get_TagFeed(tag,mediaDataFinished);
        }
    }


    function getNextMediaData() {
        API.get_Url(nextMediaUrl, mediaDataFinished);
    }

    function mediaDataFinished(data) {
        if(data === undefined || data.data === undefined) {
            console.log("ERROR!");
            return;
        }

        for(var i=0; i<data.data.length; i++) {
            mediaModel.append(data.data[i]);
            console.log(Helper.serialize(data.data[i]));
        }

        API.coverImage = mediaModel.get(0);

        if(data.pagination !== undefined && data.pagination.next_url) {
            nextMediaUrl=data.pagination.next_url;
        } else {
            nextMediaUrl=null;
        }
        dataLoaded=true;
    }

}





