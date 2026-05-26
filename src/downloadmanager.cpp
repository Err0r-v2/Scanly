#include "downloadmanager.h"
#include "mangasourcerouter.h"
#include "webpdecode.h"

#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QImage>
#include <QJsonDocument>
#include <QJsonArray>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDateTime>
#include <QDebug>

namespace {
constexpr int kTargetWidth = 1620;
constexpr int kJpegQuality = 88;

QByteArray refererFor(const QUrl &url)
{
    return url.adjusted(QUrl::RemovePath | QUrl::RemoveQuery | QUrl::RemoveFragment)
        .toString()
        .toUtf8();
}
}

DownloadManager::DownloadManager(MangaSourceRouter *client, QObject *parent)
    : QObject(parent), m_client(client)
{
    const auto base = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    m_root = base + "/chapters";
    m_coversRoot = m_root + "/_covers";
    QDir().mkpath(m_root);
    QDir().mkpath(m_coversRoot);
    loadManifest();

    connect(client, &MangaSourceRouter::chapterPagesReceived,
            this, &DownloadManager::onPages);
}

bool DownloadManager::isDownloaded(const QString &chapterId) const
{
    return m_manifest.contains(chapterId);
}

QStringList DownloadManager::localPagesFor(const QString &chapterId) const
{
    QStringList out;
    const auto entry = m_manifest.value(chapterId);
    QJsonArray arr;
    if (entry.isObject())      arr = entry.toObject().value("paths").toArray();
    else if (entry.isArray())  arr = entry.toArray(); // legacy schema
    for (const auto &v : arr)
        out << QUrl::fromLocalFile(v.toString()).toString();
    return out;
}

void DownloadManager::downloadChapter(const QString &chapterId,
                                      const QString &mangaId,
                                      const QString &mangaTitle,
                                      const QString &chapterTitle,
                                      const QString &chapterNumber,
                                      const QString &coverUrl)
{
    ensureCoverDownloaded(mangaId, coverUrl);
    if (m_jobs.contains(chapterId)) return;
    if (isDownloaded(chapterId)) {
        emit chapterDownloadFinished(chapterId);
        return;
    }
    Job j;
    j.chapterId = chapterId;
    j.mangaId = mangaId;
    j.mangaTitle = mangaTitle;
    j.chapterTitle = chapterTitle;
    j.chapterNumber = chapterNumber;
    j.coverUrl = coverUrl;
    m_jobs.insert(chapterId, j);
    emit manifestChanged();
    m_client->fetchChapterPages(chapterId);
}

QString DownloadManager::coverFilePath(const QString &mangaId) const
{
    if (mangaId.isEmpty()) return {};
    return m_coversRoot + "/" + mangaId + ".jpg";
}

QString DownloadManager::coverPathFor(const QString &mangaId) const
{
    const QString p = coverFilePath(mangaId);
    if (p.isEmpty() || !QFile::exists(p)) return {};
    return QUrl::fromLocalFile(p).toString();
}

void DownloadManager::ensureCoverDownloaded(const QString &mangaId, const QString &coverUrl)
{
    if (mangaId.isEmpty() || coverUrl.isEmpty()) return;
    const QString out = coverFilePath(mangaId);
    if (QFile::exists(out)) return;

    QNetworkRequest req(QUrl::fromUserInput(coverUrl));
    req.setRawHeader("User-Agent", "Mozilla/5.0 Scanly/0.1");
    req.setRawHeader("Referer", refererFor(QUrl::fromUserInput(coverUrl)));
    auto *reply = m_net.get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply, out, mangaId]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) return;
        QImage img;
        const QByteArray data = reply->readAll();
        if (!img.loadFromData(data) && !scanlyDecodeWebp(data, &img)) return;
        if (img.width() > 480)
            img = img.scaledToWidth(480, Qt::SmoothTransformation);
        QDir().mkpath(QFileInfo(out).absolutePath());
        if (img.save(out, "JPEG", 86))
            emit manifestChanged();
    });
}

void DownloadManager::onPages(const QString &chapterId, const QStringList &urls)
{
    if (!m_jobs.contains(chapterId)) return;
    auto &j = m_jobs[chapterId];
    j.remoteUrls = urls;
    j.localPaths.resize(urls.size());

    QDir().mkpath(m_root + "/" + chapterId);
    emit chapterDownloadStarted(chapterId, urls.size());
    pumpJob(chapterId);
}

void DownloadManager::pumpJob(const QString &chapterId)
{
    constexpr int kPerChapterConcurrency = 6;
    auto it = m_jobs.find(chapterId);
    if (it == m_jobs.end()) return;
    Job &j = it.value();
    if (j.failed) return;

    while (j.inFlight < kPerChapterConcurrency
           && j.dispatched < j.remoteUrls.size()) {
        const int idx = j.dispatched++;
        j.inFlight++;
        dispatchPage(chapterId, idx);
    }

    if (j.completed >= j.remoteUrls.size() && j.inFlight == 0)
        finalizeJob(chapterId);
}

void DownloadManager::dispatchPage(const QString &chapterId, int index)
{
    auto it = m_jobs.find(chapterId);
    if (it == m_jobs.end()) return;
    const Job &j = it.value();

    const QUrl url = QUrl::fromUserInput(j.remoteUrls.at(index));
    const QString ext = QFileInfo(url.path()).suffix().toLower();
    const QString outName = QString("%1.%2").arg(index, 3, 10, QChar('0'))
                                            .arg(ext.isEmpty() ? "jpg" : ext);
    const QString outPath = m_root + "/" + chapterId + "/" + outName;

    QNetworkRequest req(url);
    req.setRawHeader("User-Agent", "Mozilla/5.0 Scanly/0.1");
    req.setRawHeader("Referer", refererFor(url));
    auto *reply = m_net.get(req);
    connect(reply, &QNetworkReply::finished, this,
            [this, chapterId, index, outPath, reply]() {
        reply->deleteLater();
        auto it = m_jobs.find(chapterId);
        if (it == m_jobs.end()) return;
        Job &j = it.value();
        j.inFlight = qMax(0, j.inFlight - 1);

        if (j.failed) return;

        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "[Download] page failed:" << reply->errorString();
            const QString err = reply->errorString();
            j.failed = true;
            m_jobs.remove(chapterId);
            emit chapterDownloadFailed(chapterId, err);
            emit manifestChanged();
            return;
        }

        if (!saveImage(reply->readAll(), outPath)) {
            qWarning() << "[Download] save failed:" << outPath;
            j.failed = true;
            m_jobs.remove(chapterId);
            emit chapterDownloadFailed(chapterId, "Save failed");
            emit manifestChanged();
            return;
        }

        j.localPaths[index] = outPath;
        j.completed++;
        emit chapterDownloadProgress(chapterId, j.completed, j.remoteUrls.size());
        pumpJob(chapterId);
    });
}

void DownloadManager::finalizeJob(const QString &chapterId)
{
    auto it = m_jobs.find(chapterId);
    if (it == m_jobs.end()) return;
    Job &j = it.value();

    QJsonArray paths;
    for (const auto &p : j.localPaths) paths.append(p);
    QJsonObject entry{
        {"mangaId",       j.mangaId},
        {"mangaTitle",    j.mangaTitle},
        {"chapterTitle",  j.chapterTitle},
        {"chapterNumber", j.chapterNumber},
        {"downloadedAt",  QDateTime::currentDateTimeUtc().toString(Qt::ISODate)},
        {"paths",         paths},
    };
    m_manifest.insert(chapterId, entry);
    saveManifest();
    m_jobs.remove(chapterId);
    emit chapterDownloadFinished(chapterId);
    emit manifestChanged();
}

bool DownloadManager::saveImage(const QByteArray &data, const QString &outPath)
{
    QImage img;
    if (img.loadFromData(data) || scanlyDecodeWebp(data, &img)) {
        if (img.width() > kTargetWidth)
            img = img.scaledToWidth(kTargetWidth, Qt::SmoothTransformation);
        return img.save(outPath, "JPEG", kJpegQuality);
    }

    QFile f(outPath);
    if (!f.open(QIODevice::WriteOnly)) return false;
    f.write(data);
    return true;
}

void DownloadManager::removeChapter(const QString &chapterId)
{
    if (!isDownloaded(chapterId)) return;
    QString mangaId;
    const auto entry = m_manifest.value(chapterId);
    if (entry.isObject())
        mangaId = entry.toObject().value("mangaId").toString();

    QDir(m_root + "/" + chapterId).removeRecursively();
    m_manifest.remove(chapterId);

    if (!mangaId.isEmpty()) {
        bool stillHasChapters = false;
        for (auto it = m_manifest.begin(); it != m_manifest.end(); ++it) {
            if (it.value().isObject()
                && it.value().toObject().value("mangaId").toString() == mangaId) {
                stillHasChapters = true;
                break;
            }
        }
        if (!stillHasChapters) {
            const QString p = coverFilePath(mangaId);
            if (!p.isEmpty()) QFile::remove(p);
        }
    }

    saveManifest();
    emit chapterRemoved(chapterId);
    emit manifestChanged();
}

QVariantList DownloadManager::downloadedMangas() const
{
    QHash<QString, QVariantMap> byManga;
    QStringList order;
    for (auto it = m_manifest.begin(); it != m_manifest.end(); ++it) {
        if (!it.value().isObject()) continue;
        const auto o = it.value().toObject();
        const QString mid = o.value("mangaId").toString();
        const QString key = mid.isEmpty() ? QStringLiteral("__legacy__") : mid;
        if (!byManga.contains(key)) {
            QVariantMap m;
            m.insert("mangaId",    mid);
            m.insert("mangaTitle", o.value("mangaTitle").toString());
            m.insert("coverPath",  coverPathFor(mid));
            m.insert("chapterCount", 0);
            m.insert("sizeBytes",    qint64(0));
            byManga.insert(key, m);
            order.append(key);
        }
        QVariantMap &m = byManga[key];
        m["chapterCount"] = m["chapterCount"].toInt() + 1;
        m["sizeBytes"]    = m["sizeBytes"].toLongLong() + sizeForChapter(it.key());
    }
    QVariantList out;
    for (const auto &k : order) out.append(byManga.value(k));
    return out;
}

QVariantList DownloadManager::downloadedChaptersFor(const QString &mangaId) const
{
    QVariantList out;
    for (auto it = m_manifest.begin(); it != m_manifest.end(); ++it) {
        if (!it.value().isObject()) continue;
        const auto o = it.value().toObject();
        if (o.value("mangaId").toString() != mangaId) continue;
        QVariantMap m;
        m.insert("chapterId",     it.key());
        m.insert("mangaId",       o.value("mangaId").toString());
        m.insert("mangaTitle",    o.value("mangaTitle").toString());
        m.insert("chapterTitle",  o.value("chapterTitle").toString());
        m.insert("chapterNumber", o.value("chapterNumber").toString());
        m.insert("downloadedAt",  o.value("downloadedAt").toString());
        m.insert("pageCount",     o.value("paths").toArray().size());
        m.insert("sizeBytes",     sizeForChapter(it.key()));
        out.append(m);
    }
    std::sort(out.begin(), out.end(), [](const QVariant &a, const QVariant &b) {
        const auto na = a.toMap().value("chapterNumber").toString().toDouble();
        const auto nb = b.toMap().value("chapterNumber").toString().toDouble();
        if (na != nb) return na < nb;
        return a.toMap().value("chapterId").toString()
             < b.toMap().value("chapterId").toString();
    });
    return out;
}

qint64 DownloadManager::totalSizeOnDisk() const
{
    qint64 total = 0;
    QDir root(m_root);
    const auto chapters = root.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const auto &c : chapters) {
        QDir d(root.absoluteFilePath(c));
        for (const auto &fi : d.entryInfoList(QDir::Files))
            total += fi.size();
    }
    return total;
}

qint64 DownloadManager::sizeForChapter(const QString &chapterId) const
{
    qint64 total = 0;
    QDir d(m_root + "/" + chapterId);
    for (const auto &fi : d.entryInfoList(QDir::Files))
        total += fi.size();
    return total;
}

QVariantList DownloadManager::completedDownloads() const
{
    QVariantList out;
    for (auto it = m_manifest.begin(); it != m_manifest.end(); ++it) {
        QVariantMap m;
        m.insert("chapterId", it.key());
        if (it.value().isObject()) {
            const auto o = it.value().toObject();
            m.insert("mangaId",       o.value("mangaId").toString());
            m.insert("mangaTitle",    o.value("mangaTitle").toString());
            m.insert("chapterTitle",  o.value("chapterTitle").toString());
            m.insert("chapterNumber", o.value("chapterNumber").toString());
            m.insert("downloadedAt",  o.value("downloadedAt").toString());
            m.insert("pageCount",     o.value("paths").toArray().size());
        } else {
            const auto arr = it.value().toArray();
            m.insert("mangaTitle", QStringLiteral("(legacy)"));
            m.insert("pageCount", arr.size());
        }
        m.insert("sizeBytes", sizeForChapter(it.key()));
        out.append(m);
    }
    return out;
}

QVariantList DownloadManager::activeDownloads() const
{
    QVariantList out;
    for (auto it = m_jobs.begin(); it != m_jobs.end(); ++it) {
        const auto &j = it.value();
        QVariantMap m{
            {"chapterId",     j.chapterId},
            {"mangaId",       j.mangaId},
            {"mangaTitle",    j.mangaTitle},
            {"chapterTitle",  j.chapterTitle},
            {"chapterNumber", j.chapterNumber},
            {"done",          j.completed},
            {"total",         j.remoteUrls.size()},
            {"progress",      j.remoteUrls.isEmpty() ? 0.0
                                : double(j.completed) / j.remoteUrls.size()},
        };
        out.append(m);
    }
    return out;
}

void DownloadManager::loadManifest()
{
    QFile f(m_root + "/index.json");
    if (!f.open(QIODevice::ReadOnly)) return;
    m_manifest = QJsonDocument::fromJson(f.readAll()).object();
}

void DownloadManager::saveManifest()
{
    QFile f(m_root + "/index.json");
    if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate)) return;
    f.write(QJsonDocument(m_manifest).toJson(QJsonDocument::Indented));
}
