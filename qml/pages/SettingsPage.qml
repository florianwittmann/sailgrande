import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {

    id: aboutPage

    SilicaFlickable {
        anchors.fill: parent
        VerticalScrollDecorator {}

        contentHeight: lastLabel.y + lastLabel.height + 150

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
                onCheckedChanged: startPageShowPopularFeed = checked
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
                onValueChanged: streamPreviewColumnCount = value
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
                onValueChanged: streamPreviewRowCount = value
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
              text: qsTr("Data volume")
            }



        }
    }
}


