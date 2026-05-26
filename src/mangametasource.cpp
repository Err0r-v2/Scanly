#include "mangametasource.h"

#include <QDateTime>
#include <QDebug>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QStandardPaths>
#include <QDir>
#include <QUrl>
#include <QUrlQuery>

namespace {
constexpr const char *kCoverHost = "https://uploads.mangadex.org/covers";
constexpr int kMatchLimit = 5;
constexpr double kMinSimilarity = 0.45;

QString descriptionFor(const QJsonObject &attrs)
{
    const auto desc = attrs.value("description").toObject();
    for (const QString &lang : { QStringLiteral("fr"),
                                 QStringLiteral("en"),
                                 QStringLiteral("es"),
                                 QStringLiteral("ja") }) {
        const QString v = desc.value(lang).toString();
        if (!v.isEmpty()) return v;
    }
    for (auto it = desc.begin(); it != desc.end(); ++it) {
        const QString v = it.value().toString();
        if (!v.isEmpty()) return v;
    }
    return {};
}

QString primaryTitle(const QJsonObject &attrs)
{
    const auto t = attrs.value("title").toObject();
    for (const QString &lang : { QStringLiteral("en"),
                                 QStringLiteral("fr"),
                                 QStringLiteral("ja-ro"),
                                 QStringLiteral("ja") }) {
        const QString v = t.value(lang).toString();
        if (!v.isEmpty()) return v;
    }
    for (auto it = t.begin(); it != t.end(); ++it) {
        const QString v = it.value().toString();
        if (!v.isEmpty()) return v;
    }
    return {};
}

QStringList altTitles(const QJsonObject &attrs)
{
    QStringList out;
    const auto arr = attrs.value("altTitles").toArray();
    for (const auto &v : arr) {
        const auto o = v.toObject();
        for (auto it = o.begin(); it != o.end(); ++it)
            out << it.value().toString();
    }
    return out;
}

QStringList tagNames(const QJsonObject &attrs)
{
    QStringList out;
    const auto arr = attrs.value("tags").toArray();
    for (const auto &v : arr) {
        const auto a = v.toObject().value("attributes").toObject();
        const auto name = a.value("name").toObject();
        QString s = name.value("en").toString();
        if (s.isEmpty()) {
            for (auto it = name.begin(); it != name.end(); ++it) {
                s = it.value().toString();
                if (!s.isEmpty()) break;
            }
        }
        if (!s.isEmpty()) out << s;
    }
    return out;
}

QString coverFileFromRels(const QJsonArray &rels)
{
    for (const auto &v : rels) {
        const auto o = v.toObject();
        if (o.value("type").toString() != QLatin1String("cover_art")) continue;
        return o.value("attributes").toObject().value("fileName").toString();
    }
    return {};
}
}

MangaMetaSource::MangaMetaSource(QObject *parent) : QObject(parent)
{
    const auto base = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(base);
    m_cachePath = base + "/metadata.json";
    load();
}

void MangaMetaSource::fetchMetadata(const QString &mangaId, const QString &title)
{
    if (mangaId.isEmpty() || title.isEmpty()) return;
    if (m_cache.contains(mangaId)) {
        emit metadataReceived(mangaId);
        return;
    }
    if (m_pending.contains(mangaId)) return;
    m_pending.insert(mangaId);

    QUrl url("https://api.mangadex.org/manga");
    QUrlQuery q;
    q.addQueryItem("title", QString::fromUtf8(QUrl::toPercentEncoding(title.trimmed())));
    q.addQueryItem("limit", QString::number(kMatchLimit));
    q.addQueryItem("order[relevance]", "desc");
    q.addQueryItem("includes[]", "cover_art");
    url.setQuery(q);

    QNetworkRequest req(url);
    req.setRawHeader("User-Agent", "Scanly/0.1 (https://github.com/scanly)");
    auto *reply = m_net.get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply, mangaId, title]() {
        reply->deleteLater();
        m_pending.remove(mangaId);
        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "[MangaDex] search failed:" << reply->errorString();
            // Cache as failed so the UI stops showing the loading state.
            // Don't persist failures, let the next session retry.
            m_cache.insert(mangaId, QJsonObject{{"fetched", true}});
            emit metadataReceived(mangaId);
            return;
        }
        onSearchFinished(mangaId, title, reply->readAll());
    });
}

void MangaMetaSource::onSearchFinished(const QString &mangaId, const QString &title,
                                       const QByteArray &body)
{
    const auto doc = QJsonDocument::fromJson(body);
    const auto data = doc.object().value("data").toArray();
    if (data.isEmpty()) {
        qDebug() << "[MangaDex] no match for" << title;
        m_cache.insert(mangaId, QJsonObject{{"fetched", true}});
        save();
        emit metadataReceived(mangaId);
        return;
    }

    QJsonObject best;
    double bestScore = -1.0;
    for (const auto &v : data) {
        const auto o = v.toObject();
        const auto attrs = o.value("attributes").toObject();
        QStringList candidates;
        candidates << primaryTitle(attrs);
        candidates += altTitles(attrs);
        double localBest = 0.0;
        for (const auto &c : candidates) {
            const double s = titleSimilarity(title, c);
            if (s > localBest) localBest = s;
        }
        if (localBest > bestScore) {
            bestScore = localBest;
            best = o;
        }
    }

    if (bestScore < kMinSimilarity) {
        qDebug() << "[MangaDex] weak match for" << title << "score=" << bestScore;
        m_cache.insert(mangaId, QJsonObject{{"fetched", true},
                                            {"score", bestScore}});
        save();
        emit metadataReceived(mangaId);
        return;
    }

    const auto attrs = best.value("attributes").toObject();
    const auto rels  = best.value("relationships").toArray();
    const QString mdId = best.value("id").toString();
    const QString coverFile = coverFileFromRels(rels);
    const QString coverUrl = (mdId.isEmpty() || coverFile.isEmpty())
        ? QString()
        : QString("%1/%2/%3.512.jpg").arg(kCoverHost, mdId, coverFile);

    QJsonObject entry{
        {"fetched",     true},
        {"mdId",        mdId},
        {"title",       primaryTitle(attrs)},
        {"description", descriptionFor(attrs)},
        {"coverUrl",    coverUrl},
        {"year",        attrs.value("year").toInt()},
        {"status",      attrs.value("status").toString()},
        {"demographic", attrs.value("publicationDemographic").toString()},
        {"tags",        QJsonArray::fromStringList(tagNames(attrs))},
        {"score",       bestScore},
        {"fetchedAt",   QDateTime::currentDateTimeUtc().toString(Qt::ISODate)},
    };
    m_cache.insert(mangaId, entry);
    save();
    qDebug() << "[MangaDex] match for" << title << "→" << primaryTitle(attrs)
             << "score=" << bestScore;
    emit metadataReceived(mangaId);
}

QVariantMap MangaMetaSource::metadataFor(const QString &mangaId) const
{
    if (!m_cache.contains(mangaId)) return {};
    return m_cache.value(mangaId).toObject().toVariantMap();
}

void MangaMetaSource::clearCache(const QString &mangaId)
{
    if (mangaId.isEmpty()) {
        m_cache = {};
    } else {
        m_cache.remove(mangaId);
    }
    save();
}

void MangaMetaSource::load()
{
    QFile f(m_cachePath);
    if (!f.open(QIODevice::ReadOnly)) return;
    m_cache = QJsonDocument::fromJson(f.readAll()).object();
}

void MangaMetaSource::save()
{
    QFile f(m_cachePath);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate)) return;
    f.write(QJsonDocument(m_cache).toJson(QJsonDocument::Indented));
}

QString MangaMetaSource::normalized(const QString &s)
{
    QString out;
    out.reserve(s.size());
    for (const QChar &c : s) {
        if (c.isLetterOrNumber()) out.append(c.toLower());
        else if (c.isSpace())     out.append(QLatin1Char(' '));
    }
    return out.simplified();
}

double MangaMetaSource::titleSimilarity(const QString &a, const QString &b)
{
    const QString na = normalized(a);
    const QString nb = normalized(b);
    if (na.isEmpty() || nb.isEmpty()) return 0.0;
    if (na == nb) return 1.0;
    if (nb.contains(na) || na.contains(nb))
        return 0.9 * double(qMin(na.size(), nb.size())) / qMax(na.size(), nb.size());

    const auto aw = na.split(QLatin1Char(' '), Qt::SkipEmptyParts);
    const auto bw = nb.split(QLatin1Char(' '), Qt::SkipEmptyParts);
    if (aw.isEmpty() || bw.isEmpty()) return 0.0;
    int common = 0;
    for (const auto &w : aw)
        if (bw.contains(w)) ++common;
    return double(common) / double(qMax(aw.size(), bw.size()));
}
