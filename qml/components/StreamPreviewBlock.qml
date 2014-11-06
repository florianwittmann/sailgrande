import QtQuick 2.0
import Sailfish.Silica 1.0
import "../MediaStreamMode.js" as MediaStreamMode
import "../Api.js" as API

Item {

    height: header.height + grid.height
    width: parent.width

    anchors.right: parent.right

    property string streamTitle
    property int recentMediaSize: width / 3
    property bool recentMediaLoaded: false

    property string tag

    property var streamData

    property int mode : MediaStreamMode.MY_STREAM_MODE

    Item {
        id:header

        height: Theme.itemSizeMedium
        width: parent.width
        anchors.top: parent.top


        Rectangle {
            anchors.fill: parent
            color: Theme.highlightColor
            opacity : mouseAreaHeader.pressed ? 0.3 : 0
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

            text:streamTitle
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: icon.left
            anchors.rightMargin: Theme.paddingMedium
        }

        MouseArea {
            id: mouseAreaHeader
            anchors.fill: parent
            onClicked: pageStack.push(Qt.resolvedUrl("../pages/MediaStreamPage.qml"),{mode : mode, streamData: streamData, streamTitle: streamTitle})
        }
    }

    Grid {
        height: recentMediaSize * 2
        id: grid
        columns: 3
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom

        Repeater {
            visible: recentMediaLoaded
            model: recentMediaModel
            delegate: Item {
                width: recentMediaSize
                height: recentMediaSize
                SmallMediaElement{
                    mediaElement: model
                }
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: grid
        running: recentMediaLoaded == false
    }
    ListModel {
        id: recentMediaModel
    }

    function loadStreamPreviewDataFinished(data) {
        streamData = data;
        if(data === undefined || data.data === undefined) {
            recentMediaLoaded=true;
            return;
        }
        recentMediaModel.clear();
        var elementsCount = data.data.length > 6 ? 6 : data.data.length;
        for(var i=0; i<elementsCount; i++) {
            recentMediaModel.append(data.data[i]);
        }
        recentMediaLoaded=true;
    }

    function refreshContent(cb) {
        getFeed(mode,tag,true,function(data) {
            loadStreamPreviewDataFinished(data);
            cb();
        })
    }

}
