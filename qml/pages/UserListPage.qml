
import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../Api.js" as API
import "../Helper.js" as Helper
import "../components"
import "../UserListMode.js" as UserListMode



Page {
    id: page

    property var nextMediaUrl: null
    property bool dataLoaded: false
    property string pageTitle : ""
    property bool errorOccurred: false
    property var streamData: null
    property int mode: UserListMode.FOLLOWER



    SilicaListView {
        id: listView
        model: mediaModel
        anchors.fill: parent
        header: PageHeader {
            title: pageTitle
        }
        delegate: UserListItem {
            visible: dataLoaded
            item: model
        }

        VerticalScrollDecorator {
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
        getMediaData()
    }

    function getMediaData() {
        dataLoaded = false
        mediaModel.clear()

        if(mode=== UserListMode.FOLLOWER) {
            API.get_UserFollowers("self", mediaDataFinished)
        } else if(mode===UserListMode.FOLLOWING) {
            API.get_UserFollowing("self", mediaDataFinished)
        }
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
        }

        if (data.pagination !== undefined && data.pagination.next_url) {
            nextMediaUrl = data.pagination.next_url
        } else {
            nextMediaUrl = null
        }
        dataLoaded = true
    }
}
