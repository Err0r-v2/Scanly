#include "sushiscansource.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QJsonObject>
#include <QJsonValue>
#include <QRegularExpression>
#include <QRegularExpressionMatchIterator>
#include <QDebug>
#include <algorithm>
#include <cmath>
#include <limits>
#include <memory>

namespace {

struct SourceDef {
    QString key;
    QString name;
    QUrl root;
};

const QList<SourceDef> kSources{
    {QStringLiteral("yaoiscan"), QStringLiteral("yaoiscan"),
     QUrl(QStringLiteral("https://s22.yaoiscan.fr/s1/Sushi-Scan/"))},
    {QStringLiteral("anime-sama"), QStringLiteral("Anime Sama"),
     QUrl(QStringLiteral("https://s22.anime-sama.me/s1/scans/"))},
};

struct IndexEntry {
    QString href;
    QString name;
    bool directory = false;
};

QString unescapeHtml(QString s)
{
    s.replace("&amp;", "&");
    s.replace("&quot;", "\"");
    s.replace("&#039;", "'");
    s.replace("&apos;", "'");
    s.replace("&lt;", "<");
    s.replace("&gt;", ">");
    s.replace("&nbsp;", " ");
    return s.trimmed();
}

QString normalizedForSearch(QString s)
{
    s = unescapeHtml(s).toLower();
    s.replace('-', ' ');
    s.replace('_', ' ');
    return s.simplified();
}

QString encodedId(const SourceDef &source, const QString &href)
{
    return source.key + ":" + QString::fromUtf8(QUrl::toPercentEncoding(href));
}

bool decodeId(const QString &id, SourceDef *source, QString *href)
{
    const int sep = id.indexOf(':');
    if (sep <= 0)
        return false;

    const QString key = id.left(sep);
    const QString encoded = id.mid(sep + 1);
    for (const auto &candidate : kSources) {
        if (candidate.key == key) {
            if (source)
                *source = candidate;
            if (href)
                *href = QUrl::fromPercentEncoding(encoded.toUtf8());
            return true;
        }
    }
    return false;
}

QUrl urlForHref(const SourceDef &source, const QString &href)
{
    return source.root.resolved(QUrl(href));
}

QString absoluteUrlForHref(const SourceDef &source, const QString &href)
{
    return QString::fromUtf8(urlForHref(source, href).toEncoded());
}

bool isImageName(const QString &name)
{
    const QString lower = name.toLower();
    return lower.endsWith(".jpg") || lower.endsWith(".jpeg")
        || lower.endsWith(".png") || lower.endsWith(".webp")
        || lower.endsWith(".gif");
}

double firstNumber(const QString &s)
{
    static const QRegularExpression re(QStringLiteral(R"((\d+(?:[.,]\d+)?))"));
    const auto m = re.match(s);
    if (!m.hasMatch())
        return std::numeric_limits<double>::quiet_NaN();
    QString n = m.captured(1);
    n.replace(',', '.');
    return n.toDouble();
}

QList<double> numberSequence(const QString &s)
{
    QList<double> out;
    static const QRegularExpression re(QStringLiteral(R"((\d+(?:[.,]\d+)?))"));
    auto it = re.globalMatch(s);
    while (it.hasNext()) {
        QString n = it.next().captured(1);
        n.replace(',', '.');
        out.append(n.toDouble());
    }
    return out;
}

bool naturalLess(const IndexEntry &a, const IndexEntry &b)
{
    const auto aa = numberSequence(a.name);
    const auto bb = numberSequence(b.name);
    const int count = std::min(aa.size(), bb.size());
    for (int i = 0; i < count; ++i) {
        if (!qFuzzyCompare(aa.at(i) + 1, bb.at(i) + 1))
            return aa.at(i) < bb.at(i);
    }
    if (aa.size() != bb.size())
        return aa.size() < bb.size();
    return QString::localeAwareCompare(a.name, b.name) < 0;
}

QList<IndexEntry> parseAutoIndex(const QString &html)
{
    QList<IndexEntry> out;
    QRegularExpression re(
        QStringLiteral(R"RX(<a\s+href="([^"]+)"[^>]*>\s*<img[^>]+alt="([^"]+)"[^>]*>\s*([^<]+)\s*</a>)RX"),
        QRegularExpression::DotMatchesEverythingOption);
    auto it = re.globalMatch(html);
    while (it.hasNext()) {
        const auto m = it.next();
        const QString label = unescapeHtml(m.captured(3));
        if (label.compare(QStringLiteral("Parent Directory"), Qt::CaseInsensitive) == 0)
            continue;

        IndexEntry entry;
        entry.href = unescapeHtml(m.captured(1));
        entry.name = label;
        entry.directory = m.captured(2).compare(QStringLiteral("Directory"), Qt::CaseInsensitive) == 0;
        out.append(entry);
    }
    std::sort(out.begin(), out.end(), naturalLess);
    return out;
}

QString chapterNumber(const QString &name)
{
    const double n = firstNumber(name);
    if (!std::isnan(n))
        return QString::number(n, 'g', 8);
    return name;
}

QJsonObject makeManga(const SourceDef &source, const IndexEntry &entry,
                      const QString &coverUrl = {})
{
    QJsonObject attrs;
    attrs.insert("title", QJsonObject{{"fr", entry.name}});
    attrs.insert("description", QJsonObject{{"fr", source.name}});

    QJsonObject rel;
    rel.insert("type", "cover_art");
    rel.insert("attributes", QJsonObject{{"fileName", coverUrl}});

    return QJsonObject{
        {"id", encodedId(source, entry.href)},
        {"attributes", attrs},
        {"relationships", QJsonArray{rel}},
    };
}

QJsonObject makeChapter(const SourceDef &source, const IndexEntry &entry)
{
    QJsonObject attrs;
    attrs.insert("chapter", chapterNumber(entry.name));
    attrs.insert("title", QString());
    attrs.insert("translatedLanguage", "fr");
    attrs.insert("externalUrl", QJsonValue());

    QJsonObject rel;
    rel.insert("type", "scanlation_group");
    rel.insert("attributes", QJsonObject{{"name", source.name}});

    return QJsonObject{
        {"id", encodedId(source, entry.href)},
        {"attributes", attrs},
        {"relationships", QJsonArray{rel}},
    };
}

} // namespace

SushiScanSource::SushiScanSource(QObject *parent) : QObject(parent) {}

void SushiScanSource::getHtml(const QUrl &url,
                              std::function<void(const QString &)> onOk,
                              std::function<void(const QString &)> onErr)
{
    qDebug() << "[ScanMirror] GET" << url.toString();
    QNetworkRequest req(url);
    req.setRawHeader("User-Agent",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36");
    req.setRawHeader("Accept", "text/html");
    req.setRawHeader("Referer", url.adjusted(QUrl::RemovePath | QUrl::RemoveQuery).toString().toUtf8());
    req.setAttribute(QNetworkRequest::RedirectPolicyAttribute,
                     QNetworkRequest::NoLessSafeRedirectPolicy);

    auto *reply = m_net.get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply, onOk, onErr]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            const auto msg = reply->errorString();
            qWarning() << "[ScanMirror] error:" << msg;
            if (onErr) onErr(msg);
            emit errorOccurred(msg);
            return;
        }
        onOk(QString::fromUtf8(reply->readAll()));
    });
}

void SushiScanSource::searchManga(const QString &title)
{
    const QString q = normalizedForSearch(title);
    auto results = std::make_shared<QJsonArray>();
    auto pendingRoots = std::make_shared<int>(kSources.size());
    auto pendingCovers = std::make_shared<int>(0);
    auto rootsDone = std::make_shared<bool>(false);

    auto maybeEmit = [this, results, pendingRoots, pendingCovers, rootsDone]() {
        if (*rootsDone && *pendingCovers == 0) {
            qDebug() << "[ScanMirror] search results:" << results->size();
            emit searchResults(*results);
        }
    };

    for (const auto &source : kSources) {
        getHtml(source.root, [this, source, q, results, pendingRoots, pendingCovers, rootsDone, maybeEmit](const QString &html) {
            const auto entries = parseAutoIndex(html);
            QList<IndexEntry> matches;
            for (const auto &entry : entries) {
                if (!entry.directory)
                    continue;
                if (!q.isEmpty() && !normalizedForSearch(entry.name).contains(q))
                    continue;
                matches.append(entry);
                if (matches.size() >= 24)
                    break;
            }

            for (const auto &entry : matches) {
                const int resultIndex = results->size();
                results->append(makeManga(source, entry));
                ++(*pendingCovers);

                getHtml(urlForHref(source, entry.href),
                    [this, source, entry, results, resultIndex, pendingCovers, maybeEmit](const QString &mangaHtml) {
                        const auto chapters = parseAutoIndex(mangaHtml);
                        auto chapterIt = std::find_if(chapters.cbegin(), chapters.cend(),
                            [](const IndexEntry &candidate) { return candidate.directory; });
                        if (chapterIt == chapters.cend()) {
                            --(*pendingCovers);
                            maybeEmit();
                            return;
                        }

                        getHtml(urlForHref(source, chapterIt->href),
                            [source, entry, results, resultIndex, pendingCovers, maybeEmit](const QString &chapterHtml) {
                                const auto pages = parseAutoIndex(chapterHtml);
                                auto pageIt = std::find_if(pages.cbegin(), pages.cend(),
                                    [](const IndexEntry &candidate) {
                                        return !candidate.directory && isImageName(candidate.name);
                                    });
                                if (pageIt != pages.cend())
                                    (*results)[resultIndex] = makeManga(source, entry,
                                        absoluteUrlForHref(source, pageIt->href));
                                --(*pendingCovers);
                                maybeEmit();
                            },
                            [pendingCovers, maybeEmit](const QString &) {
                                --(*pendingCovers);
                                maybeEmit();
                            });
                    },
                    [pendingCovers, maybeEmit](const QString &) {
                        --(*pendingCovers);
                        maybeEmit();
                    });
            }

            --(*pendingRoots);
            if (*pendingRoots == 0)
                *rootsDone = true;
            maybeEmit();
        }, [pendingRoots, rootsDone, maybeEmit](const QString &) {
            --(*pendingRoots);
            if (*pendingRoots == 0)
                *rootsDone = true;
            maybeEmit();
        });
    }
}

void SushiScanSource::fetchChapters(const QString &mangaId, const QStringList &)
{
    SourceDef source;
    QString href;
    if (!decodeId(mangaId, &source, &href)) {
        emit chaptersReceived({});
        return;
    }

    getHtml(urlForHref(source, href), [this, source, mangaId](const QString &html) {
        QList<IndexEntry> chapters;
        const auto entries = parseAutoIndex(html);
        for (const auto &entry : entries) {
            if (entry.directory)
                chapters.append(entry);
        }

        QJsonArray out;
        for (const auto &entry : chapters)
            out.append(makeChapter(source, entry));

        qDebug() << "[ScanMirror] chapters loaded:" << out.size() << "for" << mangaId;
        emit chaptersReceived(out);
    });
}

void SushiScanSource::fetchChapterPages(const QString &chapterId)
{
    SourceDef source;
    QString href;
    if (!decodeId(chapterId, &source, &href)) {
        emit chapterPagesReceived(chapterId, {});
        return;
    }

    getHtml(urlForHref(source, href), [this, source, chapterId](const QString &html) {
        QStringList urls;
        const auto entries = parseAutoIndex(html);
        for (const auto &entry : entries) {
            if (!entry.directory && isImageName(entry.name))
                urls << absoluteUrlForHref(source, entry.href);
        }

        qDebug() << "[ScanMirror] pages:" << urls.size() << "for" << chapterId;
        emit chapterPagesReceived(chapterId, urls);
    });
}
