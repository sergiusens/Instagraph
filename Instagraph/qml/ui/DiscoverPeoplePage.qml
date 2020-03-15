import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: discoverpeoplepage

    header: PageHeader {
        title: i18n.tr("Discover People")
    }

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true

    property bool list_loading: false
    property bool clear_models: true

    function discoverPeopleDataFinished(data) {
        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = data.more_available == true ? data.next_max_id : "";
            more_available = data.more_available;
            next_coming = true;

            worker.sendMessage({'feed': 'discoverPeoplePage', 'obj': data.items, 'model': discoverPeopleModel, 'clear_model': clear_models, 'color': theme.palette.normal.baseText})

            next_coming = false;
        }

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
        discoverPeople();
    }

    function discoverPeople(next_id)
    {
        clear_models = false;
        if (!next_id) {
            discoverPeopleModel.clear()
            next_max_id = ""
            clear_models = true
        }
        instagram.explore(next_id);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: discoverpeoplepage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: discoverPeopleModel
    }

    ListView {
        id: recentActivityList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: discoverpeoplepage.header.bottom
        }
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                discoverPeople(next_max_id)
            }
        }

        clip: true
        cacheBuffer: discoverpeoplepage.height*2
        model: discoverPeopleModel
        delegate: ListItem {
            id: searchUsersDelegate
            height: layout.height
            divider.visible: false
            onClicked: {
                pageStack.push(Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: media.user.pk});
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
                        source: media.user.profile_pic_url
                    }

                    Column {
                        width: parent.width - units.gu(6)
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: media.user.username
                            wrapMode: Text.WordWrap
                            font.weight: Font.DemiBold
                            width: parent.width
                        }

                        Text {
                            text: media.user.full_name
                            wrapMode: Text.WordWrap
                            width: parent.width
                            textFormat: Text.RichText
                        }
                    }
                }

                FollowComponent {
                    id: followButton
                    height: units.gu(3.5)
                    friendship_var: media.user.friendship_status
                    userId: media.user.pk
                    just_icon: false

                    anchors.verticalCenter: parent.verticalCenter
                    SlotsLayout.position: SlotsLayout.Trailing
                    SlotsLayout.overrideVerticalPositioning: true
                }
            }
        }
        PullToRefresh {
            refreshing: list_loading && discoverPeopleModel.count == 0
            onRefresh: {
                list_loading = true
                discoverPeople()
            }
        }
    }

    Connections{
        target: instagram
        onExploreDataReady: {
            var data = JSON.parse(answer);
            discoverPeopleDataFinished(data);
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
