import QtQuick 2.0
import Sailfish.Silica 1.0
import Qt.labs.folderlistmodel 2.1

import "../components"

Page {
    id: galleryPage

    property string image_url

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + header.height
        contentWidth: parent.width

        PageHeader {
            id: header
            title: qsTr("Send picture")
        }

        Column {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            Image {
                id: sendPhoto
                source: image_url
                width: parent.width

                fillMode: Image.PreserveAspectFit
            }
        }
    }
}
