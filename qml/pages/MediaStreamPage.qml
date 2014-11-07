import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../Api.js" as API
import "../Helper.js" as Helper
import "../components"
import "../MediaStreamMode.js" as MediaStreamMode
import "../Storage.js" as Storage
import "../CoverMode.js" as CoverMode

Page {
    id: page

    property var nextMediaUrl: null
    property bool dataLoaded: false

    property int mode

    property string streamTitle
    property bool errorOccurred: false
    property var streamData: null
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
        }

        PullDownMenu {

            MenuItem {
                visible: mode === MediaStreamMode.TAG_MODE && tag !== ""
                text: qsTr("Pin this tag feed")
                onClicked: {
                    Storage.set("favtag", tag)
                    pageStack.replaceAbove(null,
                                           Qt.resolvedUrl("StartPage.qml"))
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

    Component.onCompleted: {
        if (streamData !== null) {
            mediaDataFinished(streamData)
            setCover(CoverMode.SHOW_FEED, streamData)
        } else {
            getMediaData(true)
            getFeed(mode, tag, true, function (data) {
                setCover(CoverMode.SHOW_FEED, data)
            })
        }
    }

    function getMediaData(cached) {
        dataLoaded = false
        mediaModel.clear()
        getFeed(mode, tag, cached, mediaDataFinished)
    }

    function getNextMediaData() {
        API.get_Url(nextMediaUrl, mediaDataFinished)
    }

    function mediaDataFinished(data) {
        if (data === undefined || data.data === undefined) {
            dataLoaded = true
            errorOccurred = true
            return
        }
        errorOccurred = false

        for (var i = 0; i < data.data.length; i++) {
            mediaModel.append(data.data[i])
            console.log(Helper.serialize(data.data[i]))
        }

        var url = mediaModel.get(0).images.thumbnail.url
        var username = mediaModel.get(0).user.username
        setCoverImage(url, username)

        if (data.pagination !== undefined && data.pagination.next_url) {
            nextMediaUrl = data.pagination.next_url
        } else {
            nextMediaUrl = null
        }
        dataLoaded = true
    }
}
