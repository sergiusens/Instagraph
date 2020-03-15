import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: userstoriespage

    header: PageHeader {
        StyleHints {
            backgroundColor: "transparent"
            foregroundColor: "#ffffff"
            dividerColor: "transparent"
        }
        contents: Rectangle {
            anchors.fill: parent
            color: "transparent"

            Row {
                spacing: units.gu(1)
                width: parent.width
                anchors {
                    verticalCenter: parent.verticalCenter
                }

                Item {
                    width: units.gu(4)
                    height: width

                    CircleImage {
                        id: feed_user_profile_image
                        width: parent.width
                        height: width
                        source: typeof user !== 'undefined' ? user.profile_pic_url : "../images/not_found_user.jpg"
                    }

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: user.pk});
                        }
                    }
                }

                Label {
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    text: typeof user !== 'undefined' ? user.username : ""
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                    color: theme.palette.highlighted.baseText
                    layer.enabled: true
                    layer.effect: DropShadow {
                        verticalOffset: 2
                        horizontalOffset: 2
                        spread: 0.4
                    }

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: user.pk});
                        }
                    }
                }

                Label {
                    id: timeAgo
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                    color: theme.palette.normal.baseText
                    layer.enabled: true
                    layer.effect: DropShadow {
                        verticalOffset: 2
                        horizontalOffset: 2
                        spread: 0.4
                    }
                }
            }
        }
    }

    property var userId
    property var user
    property int progressTime: 0

    property var allUsers: []
    property var allItems: []

    property bool getting: false

    function refreshTimers() {

    }

    function userReelsMediaFeedDataFinished(data) {
        worker.sendMessage({'feed': 'userStoriesPage', 'obj': data.items, 'model': userStoriesModel, 'clear_model': true, 'color': theme.palette.normal.baseText})

        user = data.user

        timeAgo.text = Helper.milisecondsToString(data.items[0].taken_at, true)

        getting = false

        // Mark Media Seen
        var reels = {};

        var myDate = new Date();
        var time = myDate.getTime();
        var seenAt = time - (3*data.items.length);

        for (var i = 0; i < data.items.length; i++) {
            var item = data.items[i];

            var itemTakenAt = item.taken_at;
            if (seenAt < itemTakenAt) {
                seenAt = itemTakenAt + 2;
            }

            if (seenAt > time) {
                seenAt = time;
            }

            var itemSourceId = item.user.pk;

            var reelId = item.id + '_' + itemSourceId;

            reels[reelId] = [itemTakenAt+'_'+seenAt];

            seenAt += Math.floor(Math.random() * 3) + 1;
        }

        instagram.markStoryMediaSeen(JSON.stringify(reels));
    }

    WorkerScript {
        id: worker
        source: "../js/Worker.js"
        onMessage: {
            console.log(msg)
        }
    }

    function getUserReelsMediaFeed() {
        instagram.getUserReelsMediaFeed(userId);
    }

    Component.onCompleted: {
        getUserReelsMediaFeed()
    }

    Timer {
        id: timer
        interval: 4000
        running: false
        repeat: false
        onTriggered: {
            userStoriesList.nextSlide()
        }
        onRunningChanged: {
            progressTime = 0
            if (running == true) {
                progressTimer.start()
            } else {
                progressTimer.stop()
            }
        }
    }

    Timer {
        id: progressTimer
        interval: 100
        running: false
        repeat: true
        onTriggered: {
            progressTime += 100
        }
    }

    Row {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: parent.top
            topMargin: units.gu(0.3)
        }
        z: 100
        spacing: units.gu(0.5)

        Repeater {
            id: progressRepeater
            model: userStoriesModel.count

            ProgressBar {
                width: (parent.width - (userStoriesModel.count-1)*units.gu(0.5))/userStoriesModel.count
                value: index == userStoriesList.currentIndex ? (getting ? 4000 : progressTime) : (index < userStoriesList.currentIndex ? 4000 : 0)
                minimumValue: 0
                maximumValue: 4000
            }
        }
    }

    ListModel {
        id: userStoriesModel
    }

    ListView {
        id: userStoriesList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: parent.top
        }

        snapMode: ListView.SnapOneItem
        orientation: Qt.Horizontal
        highlightMoveDuration: UbuntuAnimation.FastDuration
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true
        clip: true
        interactive: false

        model: userStoriesModel
        delegate: Item {
            width: userstoriespage.width
            height: width/image_versions2.candidates[0].width*image_versions2.candidates[0].height

            Image {
                id: feed_image
                width: parent.width
                height:parent.height
                fillMode: Image.PreserveAspectCrop
                source: image_versions2.candidates[0].url
                sourceSize: Qt.size(width,height)
                asynchronous: true
                cache: true // maybe false
                smooth: false

                onStatusChanged: {
                    if (status == Image.Ready) {
                        if (userStoriesList.currentIndex == 0) {
                            timer.start()
                        }
                    }
                }

                Connections {
                    target: userStoriesList
                    onCurrentIndexChanged: {
                        if (feed_image.status == Image.Ready) {
                            timer.stop()
                            timer.start()
                        }
                    }
                }
            }

            MouseArea {
                anchors {
                    fill: parent
                }
                onClicked: {
                    userStoriesList.nextSlide()
                }
                onPressAndHold: {

                }
                onReleased: {

                }
            }
        }

        // Go to next slide, if possible
        function nextSlide() {
            if (userStoriesList.currentIndex < userStoriesList.model.count-1) {
                userStoriesList.currentIndex++
                timeAgo.text = Helper.milisecondsToString(userStoriesModel.get(userStoriesList.currentIndex).taken_at, true)
            } else {
                if (allUsers.indexOf(userId) != allUsers.length-1) {
                    // next user
                    userId = allUsers[allUsers.indexOf(userId)+1]
                    getUserReelsMediaFeed()
                    getting = true
                    timer.stop()
                }
            }
        }

        // Go to previous slide, if possible
        function previousSlide() {
            if (userStoriesList.currentIndex > 0) {
                userStoriesList.currentIndex--
                timeAgo.text = Helper.milisecondsToString(userStoriesModel.get(userStoriesList.currentIndex).taken_at, true)
            } else {
                if (allUsers.indexOf(userId) != 0) {
                    // prev user
                    userId = allUsers[allUsers.indexOf(userId)-1]
                    getUserReelsMediaFeed()
                    getting = true
                    timer.stop()
                }
            }
        }
    }

    Connections{
        target: instagram
        onUserReelsMediaFeedDataReady: {
            var data = JSON.parse(answer);
            userReelsMediaFeedDataFinished(data)
        }
        onMarkStoryMediaSeenDataReady: {

        }
    }
}
