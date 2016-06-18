import QtQuick 2.0

Image {
    opacity: mousearea.pressed ? 0.7 : 1
    anchors.fill: parent
    source: mediaElement.image_versions2.candidates[mediaElement.image_versions2.candidates.length-1].url

    property var mediaElement;

    Image {
        property int size: parent.width * 0.2

       anchors.centerIn: parent
       source:  "image://theme/icon-cover-play"
       width: size
       height: size
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
