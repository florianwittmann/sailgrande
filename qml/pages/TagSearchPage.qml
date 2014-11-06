import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../Api.js" as API
import "../MediaStreamMode.js" as MediaStreamMode

Page {

    property bool dataLoaded : false
    property bool loadingMore : false


    property int pageNr : 1
    id: tagsPage


    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: header
            title: qsTr("Search for tag")
        }

        SearchField {
            anchors.top: header.bottom
            id: searchField
            width: parent.width

            onTextChanged: {
                timerSearchTags.restart();
            }
        }




    SilicaListView {
        id: list
        anchors.top: searchField.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        visible: dataLoaded
        model: tagsModel
        clip: true

        delegate: BackgroundItem {

            id: delegate

            Label {
                text: name + " (" + media_count + "x)"
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                font.pixelSize: Theme.fontSizeMedium

            }

            onClicked: {
                pageStack.replace(Qt.resolvedUrl("MediaStreamPage.qml"),{mode : MediaStreamMode.TAG_MODE, tag:name , streamTitle: 'Tagged with ' + name })
            }
       }

        ListModel {
            id: tagsModel
        }


        VerticalScrollDecorator { }

    }
    }
    BusyIndicator {
        anchors.centerIn: parent
        running: dataLoaded == false && searchField.text.trim() !== ""
        size: BusyIndicatorSize.Large
    }

    function searchTagsData(searchTerm) {
        if(searchTerm.trim() === "")
            return;

        API.get_Tags(searchTerm, tagsDataSearched);
    }

    function tagsDataSearched(data) {
        tagsModel.clear();
        loadingMore = false;
        for(var i=0; i<data.data.length; i++) {
            tagsModel.append(data.data[i]);
        }
        dataLoaded = true;

    }

    Component.onCompleted: {
        getTagsData();
    }


    Timer {
         id: timerSearchTags
         interval: 600
         running: false
         repeat: false
         onTriggered: searchTagsData(searchField.text)
     }



}




