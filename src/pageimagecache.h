#pragma once

#include <QObject>
#include <QHash>
#include <QNetworkAccessManager>
#include <QSet>
#include <QStringList>

class PageImageCache : public QObject
{
    Q_OBJECT
public:
    explicit PageImageCache(QObject *parent = nullptr);

    Q_INVOKABLE void prepare(const QStringList &urls);
    Q_INVOKABLE QString displayUrl(const QString &url);

signals:
    void changed();

private:
    QNetworkAccessManager m_net;
    QHash<QString, QString> m_resolved;
    QSet<QString> m_pending;
    QStringList m_queue;
    int m_inFlight = 0;
    int m_maxConcurrent = 4;
    QString m_root;

    void enqueue(const QString &url);
    void pump();
    void startFetch(const QString &url);
    QString cachePathFor(const QString &url) const;
    bool saveDisplayImage(const QByteArray &data, const QString &path) const;
};
