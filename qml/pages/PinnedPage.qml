import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../FavManager.js" as FavManager
import "../MediaStreamMode.js" as MediaStreamMode
import "../Storage.js" as Storage

Page {

SilicaListView {

    anchors.fill: parent

    header: PageHeader {
        title: qsTr("Pinned tags")
    }

    id: pinnedTags
    model: favTagsModel

    height: 800
    clip: true

    delegate: Item {
        id: tagListItem
        property bool menuOpen: favContextMenu != null
                                && favContextMenu.parent === tagListItem
        width: parent.width
        height: menuOpen ? favContextMenu.height
                           + contentItem.height : contentItem.height

        BackgroundItem {
            id: contentItem
            height: Theme.itemSizeMedium
            width: parent.width

            Label {
                anchors.centerIn: parent
                text: favTagName
            }
            onClicked: pageStack.push(Qt.resolvedUrl(
                                          "MediaStreamPage.qml"), {
                                          mode: MediaStreamMode.TAG_MODE,
                                          tag: favTagName,
                                          streamTitle: 'Tagged with ' + favTagName
                                      })
            onPressAndHold: {
                favContextMenu.show(tagListItem)
            }

        }

            ContextMenu {
                id: favContextMenu
                MenuItem {
                    text: qsTr("Remove")
                    onClicked: remove()


                    function remove() {
                        var idx = index
                        remorse.execute(tagListItem, "Removing", function() {
                            FavManager.delFavTag(favTagName)
                            if(FavManager.favTag===favTagName)  {
                                FavManager.favTag = FavManager.favTags.length > 0 ? FavManager.favTags[0] : ""
                                console.log("set fav tag to " + FavManager.favTag)
                                Storage.set("favtag", FavManager.favTag)
                            }

                            saveFavTags()
                            refreshFavTags()
                        })
                    }

                }
                MenuItem {
                    text: qsTr("Set as favorite")
                    onClicked: {
                        FavManager.favTag = favTagName
                        Storage.set("favtag", favTagName)
                    }
                }
            }

             RemorseItem { id: remorse }
    }


    ListModel {
        id: favTagsModel
    }

    Component.onCompleted: {
        refreshFavTags()
    }



}
function refreshFavTags() {
    var favTags = FavManager.getFavTags()
    favTagsModel.clear()
    for (var i = 0; i < favTags.length; i++) {
        favTagsModel.append({
                                favTagName: favTags[i]
                            })
    }
}
}

