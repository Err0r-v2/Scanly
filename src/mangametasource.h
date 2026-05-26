#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QJsonObject>
#include <QSet>
#include <QString>
#include <QStringList>
#include <QVariantMap>

class MangaMetaSource : public QObject
{
    Q_OBJECT
public:
    explicit MangaMetaSource(QObject *parent = nullptr);

    Q_INVOKABLE void fetchMetadata(const QString &mangaId, const QString &title);
    Q_INVOKABLE QVariantMap metadataFor(const QString &mangaId) const;
    Q_INVOKABLE void clearCache(const QString &mangaId);

signals:
    void metadataReceived(const QString &mangaId);

private:
    QNetworkAccessManager m_net;
    QJsonObject m_cache;
    QSet<QString> m_pending;
    QString m_cachePath;

    void load();
    void save();
    void onSearchFinished(const QString &mangaId, const QString &title,
                          const QByteArray &body);
    static QString normalized(const QString &s);
    static double titleSimilarity(const QString &a, const QString &b);
};
