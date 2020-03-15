import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Content 1.1
import QtMultimedia 5.4

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: usersfollowingspage

    property var userId

    property bool list_loading: false
    property bool clear_models: true

    header: PageHeader {
        title: i18n.tr("Followings")
    }

    function userFollowingsDataFinished(data) {
        userFollowingsModel.clear()

        worker.sendMessage({'feed': 'UserFollowingsPage', 'obj': data.users, 'model': userFollowingsModel, 'clear_model': clear_models, 'color': theme.palette.normal.baseText})

        list_loading = false
    }

    WorkerScript {
        id: worker
        source: "../js/SimpleWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    Component.onCompleted: {
        getUserFollowings();
    }

    function getUserFollowings(next_id)
    {
        clear_models = false
        if (!next_id) {
            userFollowingsModel.clear()
            clear_models = true
        }
        instagram.getUserFollowings(userId);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: usersfollowingspage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: userFollowingsModel
    }

    ListView {
        id: userFollowingsList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: usersfollowingspage.header.bottom
        }
        onMovementEnded: {
        }

        clip: true
        cacheBuffer: parent.height*2
        model: userFollowingsModel
        delegate: ListItem {
            id: userFollowingsDelegate
            height: layout.height
            divider.visible: false
            onClicked: {
                pageStack.push(Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: pk});
            }

            SlotsLayout {
                id: layout
                anchors.centerIn: parent

                padding.leading: 0
                padding.trailing: 0
                padding.top: units.gu(1)
                padding.bottom: units.gu(1)

                mainSlot: Row {
                    id: label
                    spacing: units.gu(1)
                    width: parent.width - followButton.width

                    CircleImage {
                        width: units.gu(5)
                        height: width
                        source: profile_pic_url
                    }

                    Column {
                        width: parent.width
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: username
                            wrapMode: Text.WordWrap
                            font.weight: Font.DemiBold
                            width: parent.width
                        }

                        Text {
                            text: full_name
                            wrapMode: Text.WordWrap
                            width: parent.width
                            textFormat: Text.RichText
                        }
                    }
                }

                FollowComponent {
                    id: followButton
                    height: units.gu(3.5)
                    friendship_var: {"following": true, "outgoing_request": false}
                    userId: pk
                    just_icon: false

                    anchors.verticalCenter: parent.verticalCenter
                    SlotsLayout.position: SlotsLayout.Trailing
                    SlotsLayout.overrideVerticalPositioning: true
                }
            }
        }
        PullToRefresh {
            refreshing: list_loading && userFollowingsModel.count == 0
            onRefresh: {
                list_loading = true
                getUserFollowings()
            }
        }
    }

    Connections{
        target: instagram
        onUserFollowingsDataReady: {
            var data = JSON.parse(answer);
            userFollowingsDataFinished(data);
        }
    }
}
