#include "pageimagecache.h"
#include "webpdecode.h"

#include <QCryptographicHash>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QImage>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QStandardPaths>
#include <QUrl>

namespace {
constexpr int kTargetWidth = 1620;
constexpr int kJpegQuality = 90;

QByteArray refererFor(const QUrl &url)
{
    return url.adjusted(QUrl::RemovePath | QUrl::RemoveQuery | QUrl::RemoveFragment)
        .toString()
        .toUtf8();
}
}

PageImageCache::PageImageCache(QObject *parent) : QObject(parent)
{
    m_root = QStandardPaths::writableLocation(QStandardPaths::CacheLocation)
        + "/reader-pages";
    QDir().mkpath(m_root);
}

void PageImageCache::prepare(const QStringList &urls)
{
    for (const auto &url : urls)
        displayUrl(url);
}

QString PageImageCache::displayUrl(const QString &url)
{
    if (url.startsWith("file://")) {
        const QString path = cachePathFor(url);
        if (QFile::exists(path))
            return QUrl::fromLocalFile(path).toString();

        QFile f(QUrl(url).toLocalFile());
        if (f.open(QIODevice::ReadOnly) && saveDisplayImage(f.readAll(), path))
            return QUrl::fromLocalFile(path).toString();

        return url;
    }

    if (!url.startsWith("http"))
        return url;

    const auto it = m_resolved.constFind(url);
    if (it != m_resolved.constEnd())
        return it.value();

    const QString path = cachePathFor(url);
    if (QFile::exists(path)) {
        const QString local = QUrl::fromLocalFile(path).toString();
        m_resolved.insert(url, local);
        return local;
    }

    enqueue(url);
    return QString();
}

void PageImageCache::enqueue(const QString &url)
{
    if (m_pending.contains(url) || m_queue.contains(url))
        return;
    m_queue.append(url);
    pump();
}

void PageImageCache::pump()
{
    while (m_inFlight < m_maxConcurrent && !m_queue.isEmpty()) {
        const QString url = m_queue.takeFirst();
        if (m_pending.contains(url) || m_resolved.contains(url))
            continue;
        startFetch(url);
    }
}

void PageImageCache::startFetch(const QString &url)
{
    m_pending.insert(url);
    m_inFlight++;
    const QUrl requestUrl = QUrl::fromUserInput(url);
    QNetworkRequest req(requestUrl);
    req.setRawHeader("User-Agent", "Mozilla/5.0 Scanly/0.1");
    req.setRawHeader("Referer", refererFor(requestUrl));
    auto *reply = m_net.get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply, url]() {
        reply->deleteLater();
        m_pending.remove(url);
        m_inFlight = qMax(0, m_inFlight - 1);

        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "[PageImageCache] page fetch failed:" << reply->errorString() << url;
            m_resolved.insert(url, url);
            emit changed();
            pump();
            return;
        }

        const QByteArray data = reply->readAll();
        const QString path = cachePathFor(url);
        if (!saveDisplayImage(data, path)) {
            qWarning() << "[PageImageCache] unsupported page image"
                       << "webp=" << scanlyLooksLikeWebp(data)
                       << "magic=" << data.left(12).toHex()
                       << url;
            m_resolved.insert(url, url);
            emit changed();
            pump();
            return;
        }

        m_resolved.insert(url, QUrl::fromLocalFile(path).toString());
        emit changed();
        pump();
    });
}

QString PageImageCache::cachePathFor(const QString &url) const
{
    const QByteArray hash = QCryptographicHash::hash(url.toUtf8(), QCryptographicHash::Sha1).toHex();
    return m_root + "/" + QString::fromLatin1(hash) + ".jpg";
}

bool PageImageCache::saveDisplayImage(const QByteArray &data, const QString &path) const
{
    QImage img;
    if (!img.loadFromData(data) && !scanlyDecodeWebp(data, &img))
        return false;

    if (img.width() > kTargetWidth)
        img = img.scaledToWidth(kTargetWidth, Qt::SmoothTransformation);

    QDir().mkpath(QFileInfo(path).absolutePath());
    return img.save(path, "JPEG", kJpegQuality);
}
