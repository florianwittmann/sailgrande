import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../components"
import "../Storage.js" as Storage

Page {

    id: aboutPage

    SilicaFlickable {
        anchors.fill: parent
        VerticalScrollDecorator {}

        contentHeight: header.height + contentColumn.height + Theme.paddingMedium
        PageHeader {
            id: header
            title: qsTr("Settings")
        }

        Column {

            id: contentColumn
            spacing: 4

            anchors {
              top: header.bottom;
              topMargin: Theme.paddingMedium;
              left: parent.left;
              right: parent.right;
            }

            SectionHeader {
              text: qsTr("Startpage")
            }

            TextSwitch {
                text: qsTr("Show popular feed")
                onCheckedChanged: {
                    startPageShowPopularFeed = checked
                    Storage.set("startPageShowPopularFeed", checked ? 1 : 0);
                }
                Component.onCompleted: checked = startPageShowPopularFeed
            }

            Label {
                color: Theme.secondaryHighlightColor
                text: qsTr("Customize the column and row count of the feed previews on the startpage:")
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
            }


            Slider {
                label: qsTr("Columns")
                width: parent.width
                minimumValue: 2
                maximumValue: 5
                value: 3
                stepSize: 1
                valueText: value
                onValueChanged: {
                    streamPreviewColumnCount = value
                    Storage.set("streamPreviewColumnCount", value);
                }
                Component.onCompleted: value = streamPreviewColumnCount
            }

            Slider {
                label: qsTr("Rows")
                width: parent.width
                minimumValue: 1
                maximumValue: 4
                value: 2
                stepSize: 1
                valueText: value
                onValueChanged: {
                    streamPreviewRowCount = value
                    Storage.set("streamPreviewRowCount", value);
                }
                Component.onCompleted: value = streamPreviewRowCount
            }

            Label {
                color: Theme.secondaryHighlightColor
                text: qsTr("Shows %1 items per feed preview.").arg(streamPreviewRowCount * streamPreviewColumnCount)
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
            }

            SectionHeader {
              text: qsTr("Feeds")
            }

            TextSwitch {
                text: qsTr("Show user and date")
                onCheckedChanged: {
                    feedsShowUserDate = checked
                    Storage.set("feedsShowUserDate", checked ? 1 : 0);
                }
                Component.onCompleted: checked = feedsShowUserDate
            }

            TextSwitch {
                enabled: feedsShowUserDate
                text: qsTr("Show user and date inline")
                onCheckedChanged: {
                    feedsShowUserDateInline = checked
                    Storage.set("feedsShowUserDateInline", checked ? 1 : 0);
                }
                Component.onCompleted: checked = feedsShowUserDateInline
            }

            TextSwitch {
                text: qsTr("Show captions")
                onCheckedChanged: {
                    feedsShowCaptions = checked
                    Storage.set("feedsShowCaptions", checked ? 1 : 0);
                }
                Component.onCompleted: checked = feedsShowCaptions
            }

        }

        PullDownMenu {

            MenuItem {
                text: qsTr("Logout")

                onClicked: {
                    Storage.set("authtoken","");
                    pageStack.replaceAbove(null,Qt.resolvedUrl("AuthPage.qml"), {logout:true})
                }
            }

        }
    }

}


