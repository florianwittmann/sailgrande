#ifndef INSTAGRAMREQUEST_H
#define INSTAGRAMREQUEST_H

#include <QDir>
#include <QNetworkAccessManager>
#include <QObject>

class InstagramRequest : public QObject
{
    Q_OBJECT
public:
    explicit InstagramRequest(QObject *parent = 0);

    void request(QString endpoint, QByteArray post);
    void fileRquest(QString endpoint, QString boundary, QByteArray data);
    QString generateSignature(QJsonObject data);
    QString buildBody(QList<QList<QString> > bodies, QString boundary);

private:
    QString API_URL = "https://i.instagram.com/api/v1/";
    QString USER_AGENT = "Instagram 8.2.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)";
    QString IS_SIG_KEY = "55e91155636eaa89ba5ed619eb4645a4daf1103f2161dbfe6fd94d5ea7716095";
    QString SIG_KEY_VERSION = "4";

    QDir m_data_path;

    QNetworkAccessManager *m_manager;
    QNetworkReply *m_reply;
    QNetworkCookieJar *m_jar;

signals:
    void replySrtingReady(QVariant ans);

public slots:

private slots:
    void finishGetUrl();
    void saveCookie();
};

#endif // INSTAGRAMREQUEST_H
