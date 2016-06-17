import QtQuick 2.0
import Sailfish.Silica 1.0
import Qt.labs.folderlistmodel 2.1

import "../components"

Page {
    id: galleryPage
    //property int streamPreviewColumnCount: 3
    property int recentMediaSize: width / streamPreviewColumnCount

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + header.height
        contentWidth: parent.width

        PageHeader {
            id: header
            title: qsTr("Select picture")
        }

        Column {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            id: column

            FolderListModel{
                id: pictureModel
                folder: "file:/home/nemo/Pictures/"
                nameFilters: ["*.jpeg","*.jpg"]
            }

            PullDownMenu {
                MenuItem {
                    id: backmenu
                    visible: false
                    text: qsTr("Back")
                    onClicked: {
                        var cur_dir = pictureModel.folder.toString();
                        if(cur_dir === "file:/home/nemo/Pictures/")
                        {
                            return;
                        }

                        var arr = cur_dir.split("/");
                        var updir = arr[arr.length-2];

                        pictureModel.folder = cur_dir.replace(updir+"/","");
                    }
                }
            }

            Grid{
                id: pictureList
                width: parent.width
                height:  recentMediaSize*(Math.ceil(pictureModel.count/streamPreviewRowCount)+1)

                columns: streamPreviewColumnCount
                Repeater {
                    model: pictureModel
                    delegate: Rectangle{
                        color: "transparent"
                        height: pictureList.width/streamPreviewColumnCount
                        width: pictureList.width/streamPreviewColumnCount
                        Image {
                            visible: !fileIsDir;
                            anchors.fill: parent;
                            fillMode: Image.PreserveAspectCrop
                            source: (!fileIsDir) ? filePath : ""
                        }
                        IconButton {
                            visible: fileIsDir
                            anchors.fill: parent
                            icon.source: "image://theme/icon-m-folder?" + (pressed
                                         ? Theme.highlightColor
                                         : Theme.primaryColor)
                            onClicked: {
                                pictureModel.folder = pictureModel.folder+fileName+"/"
                                backmenu.visible = true
                            }
                            z:1
                        }
                        Text{
                            visible: fileIsDir
                            text: fileName
                            z: 2
                            anchors.fill: parent
                            verticalAlignment: Text.AlignBottom
                            horizontalAlignment: Text.AlignHCenter
                            color: Theme.highlightColor
                        }
                    }
                }
            }
        }
    }
}

