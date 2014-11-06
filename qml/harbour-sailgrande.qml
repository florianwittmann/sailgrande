import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "pages"
import "Storage.js" as Storage
import "Api.js" as API
import "MediaStreamMode.js" as MediaStreamMode

ApplicationWindow {

    property var cachedFeeds : null

    property var cachedFeedsTime : null

    initialPage: getInitialPage()
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    function getInitialPage() {

        var token = Storage.get("authtoken", "")
        if (token === "") {
            return Qt.resolvedUrl("pages/AuthPage.qml")
        } else {
            API.access_token = token
            return Qt.resolvedUrl(Qt.resolvedUrl("pages/StartPage.qml"))
        }
    }

    function getFeed(mode, tag, cached, cb) {
        if(cachedFeeds===null) cachedFeeds = {}
        if(cachedFeedsTime===null) cachedFeedsTime = {}

        var cacheKey
        if(tag===null || tag.trim()==="") {
            cacheKey = mode
        } else {
            cacheKey = mode + "-" + tag
        }

        var useCache =false;
        if(cached  && cachedFeeds[cacheKey] !== undefined && (Date.now() - cachedFeedsTime[cacheKey]) < 30000) {
            useCache = true;
        }

            if (useCache) {
                console.log("Requested " + cacheKey )
                cb(cachedFeeds[cacheKey])
            } else {

                if (mode === MediaStreamMode.MY_STREAM_MODE) {
                    API.get_UserFeed(function(data){dataFinished(cacheKey,data,cb)})
                } else if (mode === MediaStreamMode.POPULAR_MODE) {
                    API.get_Popular(function(data){dataFinished(cacheKey,data,cb)})
                }  else if (mode === MediaStreamMode.TAG_MODE && tag !== "") {
                        API.get_TagFeed(tag,function(data){dataFinished(cacheKey,data,cb)})
                    }

            }
    }




    function dataFinished(cacheKey,data,cb) {
        cachedFeedsTime[cacheKey] = Date.now()
        cachedFeeds[cacheKey] = data
        cb(data)
    }

    function setCoverImage(imageString,username) {
        API.coverImage = imageString
        API.coverUsername = username
    }

}
