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
            title: qsTr("About")
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

            Image {
                source: "../images/header_logo.png"
            }

            Label {
              text : qsTr("An unofficial client for Instagram.")
              anchors.right: parent.right
              anchors.rightMargin: Theme.paddingMedium
              anchors.left: parent.left
              anchors.leftMargin: Theme.paddingMedium
              wrapMode: Text.WordWrap
            }

            Label {
              text : "Version: 0.4.1"
              anchors.right: parent.right
              anchors.rightMargin: Theme.paddingMedium
              anchors.left: parent.left
              anchors.leftMargin: Theme.paddingMedium
              wrapMode: Text.WordWrap

            }


            SectionHeader {
              text: qsTr("License")
            }


            Label {
              text : qsTr("Source code is licensed under the MIT License (MIT).")
              anchors.right: parent.right
              anchors.rightMargin: Theme.paddingMedium
              anchors.left: parent.left
              anchors.leftMargin: Theme.paddingMedium
              wrapMode: Text.WordWrap
            }

            SectionHeader {
              text: qsTr("Contribute")
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                height: Theme.itemSizeMedium + Theme.paddingMedium


              Button {
                  anchors.bottom: parent.bottom
                  width: parent.width/2
                  text: qsTr("Translate")
                  onClicked: Qt.openUrlExternally("https://www.transifex.com/projects/p/sailgrande/")
              }

              Button {
                  anchors.bottom: parent.bottom
                  width: parent.width/2
                  text: qsTr("Report bugs")
                  onClicked: Qt.openUrlExternally("https://github.com/florianwittmann/sailgrande/issues")
              }
            }

        }
    }
}


