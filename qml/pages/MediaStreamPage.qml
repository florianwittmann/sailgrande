import QtQuick 2.0
import Sailfish.Silica 1.0

import "../Api.js" as API
import "../Helper.js" as Helper
import "../components"
import "../MediaStreamMode.js" as MediaStreamMode


Page {
    id: page

    property var nextMediaUrl :null
    property bool dataLoaded: false

    property int mode : MediaStreamMode.MY_STREAM_MODE

    property string mediaStreamTitle : switch (mode) {
                                            case MediaStreamMode.MY_STREAM_MODE:
                                                return qsTr("My Feed");
                                            case MediaStreamMode.POPULAR_MODE:
                                                return qsTr("Popular");
                                       }


    SilicaListView {
        id: listView
        model: mediaModel
        anchors.fill: parent
        header: PageHeader {
            title: mediaStreamTitle
        }
        delegate: FeedItem {
            visible: dataLoaded
            item: model
        }

        VerticalScrollDecorator {}

        PullDownMenu {

            MenuItem {
                 text: qsTr("About")
                 onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))

             }

            MenuItem {
                 text: qsTr("Refresh")
                 onClicked: getMediaData()
             }

            MenuItem {
                visible: mode === MediaStreamMode.MY_STREAM_MODE
                text: qsTr("Popular")
                onClicked: changeMode(MediaStreamMode.POPULAR_MODE);

             }

            MenuItem {
                visible: mode === MediaStreamMode.POPULAR_MODE
                text: qsTr("My Feed")
                onClicked: changeMode(MediaStreamMode.MY_STREAM_MODE);
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
         getMediaData();
     }

    function changeMode(newMode) {
        mode = newMode;
        getMediaData();
    }

    function getMediaData() {
        dataLoaded = false;
        mediaModel.clear();
        if(mode=== MediaStreamMode.MY_STREAM_MODE) {
            API.get_UserFeed(mediaDataFinished);
        } else if(mode === MediaStreamMode.POPULAR_MODE) {
            API.get_Popular(mediaDataFinished);
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





