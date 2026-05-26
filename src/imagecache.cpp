#include "imagecache.h"

#include <QNetworkDiskCache>
#include <QStandardPaths>
#include <QDir>

ImageCache::ImageCache(QObject *parent)
    : QObject(parent)
    , m_cache(new QNetworkDiskCache(this))
{
    const auto root = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QDir().mkpath(root);
    m_cache->setCacheDirectory(root + "/images");
    m_cache->setMaximumCacheSize(qint64(512) * 1024 * 1024); // 512 MB
    m_net.setCache(m_cache);
}

qint64 ImageCache::sizeOnDisk() const { return m_cache->cacheSize(); }

void ImageCache::clear() { m_cache->clear(); }

QNetworkAccessManager *ScanlyNamFactory::create(QObject *parent)
{
    auto *nam = new QNetworkAccessManager(parent);
    nam->setCache(m_cache->cache());
    return nam;
}
