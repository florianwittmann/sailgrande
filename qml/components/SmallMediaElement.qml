import QtQuick 2.0

Image {
    opacity: mousearea.pressed ? 0.7 : 1
    anchors.fill: parent
    source: mediaElement.images.thumbnail.url

    property var mediaElement;

    Image {
       anchors.centerIn: parent
       source:  "image://theme/icon-cover-play"
       width: 40
       height: 40
       visible: mediaElement.videos !== undefined
       opacity: 0.7
    }

    MouseArea {
        id: mousearea
        anchors.fill: parent
        onClicked: {
            pageStack.push(Qt.resolvedUrl("../pages/MediaDetailPage.qml"),{item:mediaElement});
        }
    }
}
