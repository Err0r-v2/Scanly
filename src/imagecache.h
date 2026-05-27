#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QQmlNetworkAccessManagerFactory>

class QNetworkDiskCache;

class ImageCache : public QObject
{
    Q_OBJECT
public:
    explicit ImageCache(QObject *parent = nullptr);

    QNetworkAccessManager *manager() { return &m_net; }
    QNetworkDiskCache *cache() { return m_cache; }

    Q_INVOKABLE qint64 sizeOnDisk() const;
    Q_INVOKABLE void clear();
    Q_INVOKABLE void clearMemoryCache();

private:
    QNetworkAccessManager m_net;
    QNetworkDiskCache *m_cache;
};

class ScanlyNamFactory : public QQmlNetworkAccessManagerFactory
{
public:
    explicit ScanlyNamFactory(ImageCache *cache) : m_cache(cache) {}
    QNetworkAccessManager *create(QObject *parent) override;

private:
    ImageCache *m_cache;
};
