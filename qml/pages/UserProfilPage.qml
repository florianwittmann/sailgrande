import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import "../components"
import "../Api.js" as API
import "../Helper.js" as Helper


Page {

    property var user

    property bool relationStatusLoaded : false

    property bool privateProfile : false;
    property bool recentMediaLoaded: false;

    property int recentMediaSize: (width - 2 * Theme.paddingMedium) / 3

    property string rel_outgoing_status : null;
    property string rel_incoming_status : null;



    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + header.height + 10
        contentWidth: parent.width

        PageHeader {
            id: header
            title: user.username
        }

        Column {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            id: column
            spacing: Theme.paddingSmall

            Item {
                width: parent.width
                height:150
                anchors.right: parent.right


                Image {
                    id: profilpic
                   width:150
                   height:150
                   anchors.right: parent.right
                   anchors.rightMargin: Theme.paddingMedium
                   source: user.profile_picture
                }

                Label {
                    id: incomingRelLabel
                    text: getOutgoingText()
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: profilpic.left
                    anchors.rightMargin: Theme.paddingMedium
                    color: Theme.primaryColor
                    truncationMode: TruncationMode.Fade

                    function getOutgoingText() {
                        if(rel_outgoing_status===null)
                            return "";
                        if(rel_outgoing_status==="follows")
                            return qsTr("You follow %1").arg(user.username);
                        if(rel_outgoing_status==="requested")
                            return qsTr("You requested to follow %1").arg(user.username);
                        if(rel_outgoing_status==="none")
                            return ""
                    }
                }

                Label {
                    text: getIncomingText()
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.right: profilpic.left
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.top: incomingRelLabel.bottom
                    color: Theme.primaryColor
                    truncationMode: TruncationMode.Fade

                    function getIncomingText() {
                        if(rel_incoming_status===null)
                            return "";
                        if(rel_incoming_status==="followed_by")
                            return qsTr("%1 follows you").arg(user.username);
                        if(rel_incoming_status==="requested_by")
                            return qsTr("%1 requested to follow you").arg(user.username);
                        if(rel_incoming_status==="blocked_by_you")
                            return qsTr("You blocked %1").arg(user.username)
                        if(rel_incoming_status==="none")
                            return ""


                    }
                }
            }



            Label {
                text: user.full_name
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Theme.highlightColor
                truncationMode: TruncationMode.Fade
                font.bold: true


            }
            Label {
                text: user.bio !== undefined ? user.bio : ""
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Theme.highlightColor
                visible: text!==""
                wrapMode: Text.Wrap

            }

            Label {
                text: user.counts !== undefined ? qsTr("%1 photos/videos posted").arg(user.counts.media) :""
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Theme.secondaryColor
                visible: text!==""
            }


            Label {
                text: user.counts !== undefined ? qsTr("Has %1 followers").arg(user.counts.followed_by) : ""
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Theme.secondaryColor
                visible: text!==""
            }



            Label {
                text: user.counts !== undefined ? qsTr("Following %1 users").arg(user.counts.follows) : ""
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Theme.secondaryColor
                visible: text!==""
            }

            Label {
                text: user.website !== undefined ? user.website :""
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Theme.secondaryColor
                visible: text!==""
                truncationMode: TruncationMode.Fade
            }


            Label {
                text: qsTr("This profile is private.")
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Theme.highlightColor
                visible: privateProfile
            }


            BusyIndicator {
                running: visible
                visible: !recentMediaLoaded
            }


            Grid {
                columns: 3
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium

                Repeater {
                    visible: recentMediaLoaded
                    model: recentMediaModel
                    delegate: Item {
                        width: recentMediaSize
                        height: recentMediaSize
                        Image {
                            opacity: mousearea.pressed ? 0.7 : 1
                            anchors.fill: parent
                            source: images.low_resolution.url

                            MouseArea {
                                id: mousearea
                                anchors.fill: parent
                                onClicked: {
                                    pageStack.push(Qt.resolvedUrl("MediaDetailPage.qml"),{item:model});
                                }
                            }
                        }
                    }
                }
            }





        }


        PullDownMenu {
            visible: relationStatusLoaded

            MenuItem {
                 text:  qsTr("Unfollow %1").arg(user.username)
                 visible:  rel_outgoing_status==="follows"
                 onClicked: {
                     API.unfollow(user.id, reloadRelationship);
                 }
             }

            MenuItem {
                 text: qsTr("Follow %1").arg(user.username)
                 visible: rel_outgoing_status==="none"
                 onClicked: {
                     API.follow(user.id, reloadRelationship);
                 }
             }



           }

    }

    ListModel {
        id: recentMediaModel

    }


    Component.onCompleted: {
        reload();
    }

    function reload() {
        API.get_UserById(user.id,reloadFinished);
        API.get_RecentMediaByUserId(user.id,recentMediaFinished)
        reloadRelationship("");
    }

    function reloadRelationship(data) {
        console.log(Helper.serialize(data))
        API.get_UserRelationshipById(user.id,userRelationshipFinished);
    }


    function reloadFinished(data) {
        if(data.meta.code===200) {
            user = data.data;
        } else {
            privateProfile = true;
        }
    }

    function recentMediaFinished(data) {
        if(data === undefined || data.data === undefined) {
            recentMediaLoaded=true;
            return;
        }
        for(var i=0; i<data.data.length; i++) {
            recentMediaModel.append(data.data[i]);
        }
        recentMediaLoaded=true;

    }

    function userRelationshipFinished(data) {
        if(data.meta.code===200) {
            rel_outgoing_status = data.data.outgoing_status
            rel_incoming_status = data.data.incoming_status
            relationStatusLoaded = true;
        }
    }
}
