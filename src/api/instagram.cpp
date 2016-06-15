/*
 * BASED ON https://github.com/mgp25/Instagram-API
 */
#include "instagram.h"
#include "instagramrequest.h"

#include <QCryptographicHash>

#include <QFileInfo>
#include <QStandardPaths>
#include <QDateTime>
#include <QUuid>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>

#include <QDataStream>

#include <QDebug>

Instagram::Instagram(QObject *parent)
    : QObject(parent)
{
    this->m_data_path =  QDir(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));

    if(!m_data_path.exists())
    {
        m_data_path.mkpath(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));
    }

    QUuid uuid;
    this->m_uuid = uuid.createUuid().toString();

    this->m_device_id = this->generateDeviceId();

    this->setUser();
}

QString Instagram::generateDeviceId()
{
    QFileInfo fi(m_data_path.absolutePath());
    QByteArray volatile_seed = QString::number(fi.created().toMSecsSinceEpoch()).toUtf8();

    QByteArray data_1 = QCryptographicHash::hash(
                        QString(this->m_username+this->m_password).toUtf8(),
                        QCryptographicHash::Md5).toHex();

    QString data_2 = QString(QCryptographicHash::hash(
                QString(data_1+volatile_seed).toUtf8(),
                QCryptographicHash::Md5).toHex());

    QString data = "android-"+data_2.left(16);

    return data;
}


void Instagram::setUser()
{
    if(this->m_username.length() == 0 or this->m_password.length() == 0)
    {
        emit error("Username anr/or password is clean");
    }
    else
    {
        QFile f_cookie(m_data_path.absolutePath()+"/cookies.dat");
        QFile f_userId(m_data_path.absolutePath()+"/userId.dat");
        QFile f_token(m_data_path.absolutePath()+"/token.dat");

        if(f_cookie.exists() && f_userId.exists() && f_token.exists())
        {
            this->m_isLoggedIn = true;
            this->m_username_id = f_userId.readAll().trimmed();
            this->m_rank_token = this->m_username_id+"_"+this->m_uuid;
            this->m_token = f_token.readAll().trimmed();

            this->doLogin();
        }
    }
}


void Instagram::login(bool forse)
{
    if(!this->m_isLoggedIn or forse)
    {
        this->setUser();
        InstagramRequest *loginRequest = new InstagramRequest();
        loginRequest->request("si/fetch_headers/?challenge_type=signup&guid="+this->m_uuid,NULL);
        QObject::connect(loginRequest,SIGNAL(replySrtingReady(QVariant)),this,SLOT(doLogin()));
    }
}

void Instagram::logout()
{
    QFile f_cookie(m_data_path.absolutePath()+"/cookies.dat");
    QFile f_userId(m_data_path.absolutePath()+"/userId.dat");
    QFile f_token(m_data_path.absolutePath()+"/token.dat");

    f_cookie.remove();
    f_userId.remove();
    f_token.remove();

    InstagramRequest *looutRequest = new InstagramRequest();
    looutRequest->request("accounts/logout/",NULL);
    QObject::connect(looutRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(doLogout(QVariant)));
}

void Instagram::doLogin()
{
    InstagramRequest *request = new InstagramRequest();
    QRegExp rx("token=(\\w+);");
    QFile f(m_data_path.absolutePath()+"/cookies.dat");
    if (!f.open(QFile::ReadOnly))
    {
        qDebug() << m_data_path.absolutePath()+"/cookies.dat";
        qDebug() << f.errorString();
        emit error("Can`t open token file");
    }
    QTextStream in(&f);
    rx.indexIn(in.readAll());
    if(rx.cap(1).length() > 0)
    {
        this->m_token = rx.cap(1);
        qDebug() << rx.cap(1);
    }
    else
    {
        emit error("Can`t find token");
    }
    QUuid uuid;

    QJsonObject data;
        data.insert("phone_id",     uuid.createUuid().toString());
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("username",     this->m_username);
        data.insert("guid",         this->m_uuid);
        data.insert("device_id",    this->m_device_id);
        data.insert("password",     this->m_password);
        data.insert("login_attempt_count", QString("0"));

    QString signature = request->generateSignature(data);
    request->request("accounts/login/",signature.toUtf8());

    QObject::connect(request,SIGNAL(replySrtingReady(QVariant)),this,SLOT(profileConnect(QVariant)));
}

void Instagram::profileConnect(QVariant profile)
{
    QJsonDocument profile_doc = QJsonDocument::fromJson(profile.toString().toUtf8());
    QJsonObject profile_obj = profile_doc.object();
    if(profile_obj["status"].toString().toUtf8() == "fail")
    {
        emit error(profile_obj["message"].toString().toUtf8());
        emit profileConnectedFail();
    }
    else
    {

        QJsonObject user = profile_obj["logged_in_user"].toObject();

        this->m_isLoggedIn = true;
        this->m_username_id = QString::number(user["pk"].toDouble(),'g', 10);
        this->m_rank_token = this->m_username_id+"_"+this->m_uuid;

        this->syncFeatures();

        emit profileConnected(profile);
    }
}


void Instagram::syncFeatures()
{
    InstagramRequest *syncRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("_uid",         this->m_username_id);
        data.insert("id",           this->m_username_id);
        data.insert("password",     this->m_password);
        data.insert("experiments",  EXPERIMENTS);

    QString signature = syncRequest->generateSignature(data);
    syncRequest->request("qe/sync/",signature.toUtf8());
}

//FIXME: uploadImage is not public yeat. Give me few weeks to optimize code
void Instagram::postImage(QFile *image, QString caption, QString upload_id)
{
    QByteArray dataStrem = image->readAll();
    QString boundary = this->m_uuid;

    if(upload_id.length() == 0)
    {
        upload_id = QDateTime::currentMSecsSinceEpoch();
    }
}

//FIXME: uploadImage is not public yeat. Give me few weeks to optimize code
void Instagram::postVideo(QFile *video)
{

}

void Instagram::editMedia(QString mediaId, QString captionText)
{
    InstagramRequest *editMediaRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("caption_text", captionText);

    QString signature = editMediaRequest->generateSignature(data);
    editMediaRequest->request("media/"+mediaId+"/edit_media/",signature.toUtf8());
    QObject::connect(editMediaRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(mediaEdited(QVariant)));
}

void Instagram::deleteMedia(QString mediaId)
{
    InstagramRequest *deleteMediaRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("media_id",    mediaId);

    QString signature = deleteMediaRequest->generateSignature(data);
    deleteMediaRequest->request("media/"+mediaId+"/delete/",signature.toUtf8());
    QObject::connect(deleteMediaRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(mediaDeleted(QVariant)));
}

void Instagram::removeSelftag(QString mediaId)
{
    InstagramRequest *removeSelftagRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);

    QString signature = removeSelftagRequest->generateSignature(data);
    removeSelftagRequest->request("usertags/"+mediaId+"/remove/",signature.toUtf8());
    QObject::connect(removeSelftagRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(removeSelftagDone(QVariant)));
}

void Instagram::postComment(QString mediaId, QString commentText)
{
    InstagramRequest *postCommentRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("comment_text", commentText);

    QString signature = postCommentRequest->generateSignature(data);
    postCommentRequest->request("media/"+mediaId+"/comment/",signature.toUtf8());
    QObject::connect(postCommentRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(commentPosted(QVariant)));
}

void Instagram::deleteComment(QString mediaId, QString commentId, QString captionText)
{
    InstagramRequest *deleteCommentRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("caption_text", captionText);

    QString signature = deleteCommentRequest->generateSignature(data);
    deleteCommentRequest->request("media/"+mediaId+"/comment/"+commentId+"/delete/",signature.toUtf8());
    QObject::connect(deleteCommentRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(commentDeleted(QVariant)));
}

//FIXME changeProfilePicture is not public yeat. Give me few weeks to optimize code
void Instagram::changeProfilePicture(QFile *photo)
{

}

void Instagram::removeProfilePicture()
{
    InstagramRequest *removeProfilePictureRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);

    QString signature = removeProfilePictureRequest->generateSignature(data);
    removeProfilePictureRequest->request("maccounts/remove_profile_picture/",signature.toUtf8());
    QObject::connect(removeProfilePictureRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(profilePictureDeleted(QVariant)));
}

void Instagram::setPrivateAccount()
{
    InstagramRequest *setPrivateRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);

    QString signature = setPrivateRequest->generateSignature(data);
    setPrivateRequest->request("accounts/set_private/",signature.toUtf8());
    QObject::connect(setPrivateRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(setProfilePrivate(QVariant)));
}

void Instagram::setPublicAccount()
{
    InstagramRequest *setPublicRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);

    QString signature = setPublicRequest->generateSignature(data);
    setPublicRequest->request("accounts/set_public/",signature.toUtf8());
    QObject::connect(setPublicRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(setProfilePublic(QVariant)));
}

void Instagram::getProfileData()
{
    InstagramRequest *getProfileRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);

    QString signature = getProfileRequest->generateSignature(data);
    getProfileRequest->request("accounts/current_user/?edit=true",signature.toUtf8());
    QObject::connect(getProfileRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(profileDataReady(QVariant)));
}
/**
 * Edit profile.
 *
 * @param QString url
 *   Url - website. "" for nothing
 * @param QString phone
 *   Phone number. "" for nothing
 * @param QString first_name
 *   Name. "" for nothing
 * @param QString email
 *   Email. Required.
 * @param bool gender
 *   Gender. male = true , female = false
 */
void Instagram::editProfile(QString url, QString phone, QString first_name, QString biography, QString email, bool gender)
{
    InstagramRequest *editProfileRequest = new InstagramRequest();
    QString gen_string;
    if(gender)
    {
        gen_string = "1";
    }
    else
    {
        gen_string = "0";
    }

    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("external_url", url);
        data.insert("phone_number", phone);
        data.insert("username",     this->m_username);
        data.insert("full_name",    first_name);
        data.insert("biography",    biography);
        data.insert("email",        email);
        data.insert("gender",       gen_string);

    QString signature = editProfileRequest->generateSignature(data);
    editProfileRequest->request("accounts/edit_profile/",signature.toUtf8());
    QObject::connect(editProfileRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(editDataReady(QVariant)));
}

void Instagram::getUsernameInfo(QString usernameId)
{
    InstagramRequest *getUsernameRequest = new InstagramRequest();
    getUsernameRequest->request("users/"+usernameId+"/info/",NULL);
    QObject::connect(getUsernameRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(usernameDataReady(QVariant)));
}

void Instagram::getRecentActivity()
{
    InstagramRequest *getRecentActivityRequest = new InstagramRequest();
    getRecentActivityRequest->request("news/inbox/?",NULL);
    QObject::connect(getRecentActivityRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(recentActivityDataReady(QVariant)));
}

void Instagram::getFollowingRecentActivity()
{
    InstagramRequest *getFollowingRecentRequest = new InstagramRequest();
    getFollowingRecentRequest->request("news/?",NULL);
    QObject::connect(getFollowingRecentRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(followingRecentDataReady(QVariant)));
}

void Instagram::getUserTags(QString usernameId)
{
    InstagramRequest *getUserTagsRequest = new InstagramRequest();
    getUserTagsRequest->request("usertags/"+usernameId+"/feed/?rank_token="+this->m_rank_token+"&ranked_content=true&",NULL);
    QObject::connect(getUserTagsRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(userTagsDataReady(QVariant)));
}

void Instagram::tagFeed(QString tag)
{
    InstagramRequest *getTagFeedRequest = new InstagramRequest();
    getTagFeedRequest->request("feed/tag/"+tag+"/?rank_token="+this->m_rank_token+"&ranked_content=true&",NULL);
    QObject::connect(getTagFeedRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(tagFeedDataReady(QVariant)));
}

void Instagram::getTimeLine(QString max_id)
{
    QString target ="feed/timeline/?rank_token="+this->m_rank_token+"&ranked_content=true&";

    if(max_id.length() > 0)
    {
        target += "&max_id="+max_id;
    }

    InstagramRequest *getTimeLineRequest = new InstagramRequest();
    getTimeLineRequest->request(target,NULL);
    QObject::connect(getTimeLineRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(timeLineDataReady(QVariant)));
}

void Instagram::getUsernameFeed(QString usernameID, QString maxid, QString minTimestamp)
{
    QString endpoint;
    endpoint = "feed/user/"+usernameID+"/?rank_token="+this->m_rank_token;
    if(maxid.length() > 0)
    {
        endpoint += "&max_id="+maxid;
    }
    if(minTimestamp.length() > 0)
    {
        endpoint += "&min_timestamp="+minTimestamp;
    }
    endpoint += "&ranked_content=true";

    InstagramRequest *getUserTimeLineRequest = new InstagramRequest();
    getUserTimeLineRequest->request(endpoint,NULL);
    QObject::connect(getUserTimeLineRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(userTimeLineDataReady(QVariant)));
}

void Instagram::getPopularFeed()
{
    InstagramRequest *getPopularFeedRequest = new InstagramRequest();
    getPopularFeedRequest->request("feed/popular/?people_teaser_supported=1&rank_token="+this->m_rank_token+"&ranked_content=true&",NULL);
    QObject::connect(getPopularFeedRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(popularFeedDataReady(QVariant)));

}

void Instagram::getMediaLikers(QString mediaId)
{
    InstagramRequest *getMediaLikersRequest = new InstagramRequest();
    getMediaLikersRequest->request("media/"+mediaId+"/likers/?",NULL);
    QObject::connect(getMediaLikersRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(mediaLikersDataReady(QVariant)));
}

void Instagram::like(QString mediaId)
{
    InstagramRequest *likeRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("media_id",     mediaId);

    QString signature = likeRequest->generateSignature(data);
    likeRequest->request("media/"+mediaId+"/like/",signature.toUtf8());
    QObject::connect(likeRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(likeDataReady(QVariant)));
}

void Instagram::unLike(QString mediaId)
{
    InstagramRequest *unLikeRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("media_id",     mediaId);

    QString signature = unLikeRequest->generateSignature(data);
    unLikeRequest->request("media/"+mediaId+"/unlike/",signature.toUtf8());
    QObject::connect(unLikeRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(unLikeDataReady(QVariant)));
}

void Instagram::getMediaComments(QString mediaId)
{
    InstagramRequest *getMediaCommentsRequest = new InstagramRequest();
    getMediaCommentsRequest->request("media/"+mediaId+"/comments/?",NULL);
    QObject::connect(getMediaCommentsRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(mediaCommentsDataReady(QVariant)));
}

void Instagram::follow(QString userId)
{
    InstagramRequest *followRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("user_id",     userId);

    QString signature = followRequest->generateSignature(data);
    followRequest->request("friendships/create/"+userId+"/",signature.toUtf8());
    QObject::connect(followRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(followDataReady(QVariant)));
}

void Instagram::unFollow(QString userId)
{
    InstagramRequest *unFollowRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("user_id",     userId);

    QString signature = unFollowRequest->generateSignature(data);
    unFollowRequest->request("friendships/destroy/"+userId+"/",signature.toUtf8());
    QObject::connect(unFollowRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(unFollowDataReady(QVariant)));
}

void Instagram::block(QString userId)
{
    InstagramRequest *blockRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("user_id",     userId);

    QString signature = blockRequest->generateSignature(data);
    blockRequest->request("friendships/block/"+userId+"/",signature.toUtf8());
    QObject::connect(blockRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(blockDataReady(QVariant)));
}

void Instagram::unBlock(QString userId)
{
    InstagramRequest *unBlockRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("user_id",     userId);

    QString signature = unBlockRequest->generateSignature(data);
    unBlockRequest->request("friendships/unblock/"+userId+"/",signature.toUtf8());
    QObject::connect(unBlockRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(unBlockDataReady(QVariant)));
}

void Instagram::userFriendship(QString userId)
{
    InstagramRequest *userFriendshipRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("user_id",     userId);

    QString signature = userFriendshipRequest->generateSignature(data);
    userFriendshipRequest->request("friendships/show/"+userId+"/",signature.toUtf8());
    QObject::connect(userFriendshipRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(userFriendshipDataReady(QVariant)));
}

void Instagram::getLikedMedia()
{
    InstagramRequest *getLikedMediaRequest = new InstagramRequest();
    getLikedMediaRequest->request("feedd/liked/?",NULL);
    QObject::connect(getLikedMediaRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(likedMediaDataReady(QVariant)));
}

/*
 * Return json string
 * {
 *   "username":    STRING  Checking username,
 *   "available":   BOOL    Aviable to registration,
 *   "status":      STRING  Status of request,
 *   "error":       STRING  Error string if aviable
 *   }
 */
void Instagram::checkUsername(QString username)
{
    InstagramRequest *checkUsernameRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_csrftoken",   QString("missing"));
        data.insert("username",     username);

    QString signature = checkUsernameRequest->generateSignature(data);
    checkUsernameRequest->request("users/check_username/",signature.toUtf8());
    QObject::connect(checkUsernameRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(usernameCheckDataReady(QVariant)));
}
/*
 * Return JSON string
 * {
 *  "status": STRING    Status of request,
 *  "errors":{
 *            ARRAY     Array of errors if aviable
 *      "password":[],  STRING  Error message if password wrong if aviable
 *      "email":[],     STRING  Error message if email wrong if aviable
 *      "FIELD_ID":[]   STRING  Error message if FIELD_ID wrong if aviable
 *  },
 *  "account_created",  BOOL Status of creation account
 *  "created_user"      ARRAY Array of new user params
 *  }
 *
 */
void Instagram::createAccount(QString username, QString password, QString email)
{
    InstagramRequest *createAccountRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",               this->m_uuid);
        data.insert("_csrftoken",          QString("missing"));
        data.insert("username",            username);
        data.insert("first_name",          QString(""));
        data.insert("guid",                this->m_uuid);
        data.insert("device_id",           this->m_device_id);
        data.insert("email",               email);
        data.insert("force_sign_up_code",  QString(""));
        data.insert("qs_stamp",            QString(""));
        data.insert("password",            password);

    QString signature = createAccountRequest->generateSignature(data);
    createAccountRequest->request("accounts/create/",signature.toUtf8());
    QObject::connect(createAccountRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(createAccountDataReady(QVariant)));
}

void Instagram::searchUsername(QString username)
{
    InstagramRequest *searchUsernameRequest = new InstagramRequest();
    searchUsernameRequest->request("users/"+username+"/usernameinfo/", NULL);
    QObject::connect(searchUsernameRequest,SIGNAL(replySrtingReady(QVariant)), this, SIGNAL(searchUsernameDataReady(QVariant)));
}
