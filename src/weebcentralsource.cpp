#include "weebcentralsource.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonValue>
#include <QRegularExpression>
#include <QUrlQuery>
#include <QDebug>
#include <algorithm>

namespace {

constexpr const char *kHost      = "https://weebcentral.com";
constexpr const char *kSourceKey = "weebcentral";

QString unescapeHtml(QString s)
{
    // Numeric entities (decimal &#39; and hex &#x27;), must run before the
    // generic &amp; replacement so we don't accidentally re-escape.
    static const QRegularExpression decRx("&#(\\d+);");
    auto it = decRx.globalMatch(s);
    QString out; out.reserve(s.size());
    int last = 0;
    while (it.hasNext()) {
        const auto m = it.next();
        out.append(s.mid(last, m.capturedStart() - last));
        out.append(QChar(m.captured(1).toInt()));
        last = m.capturedEnd();
    }
    out.append(s.mid(last));
    s = out;

    static const QRegularExpression hexRx("&#x([0-9a-fA-F]+);");
    auto hit = hexRx.globalMatch(s);
    out.clear(); last = 0;
    while (hit.hasNext()) {
        const auto m = hit.next();
        out.append(s.mid(last, m.capturedStart() - last));
        out.append(QChar(m.captured(1).toInt(nullptr, 16)));
        last = m.capturedEnd();
    }
    out.append(s.mid(last));
    s = out;

    s.replace("&amp;", "&");
    s.replace("&quot;", "\"");
    s.replace("&apos;", "'");
    s.replace("&lt;", "<");
    s.replace("&gt;", ">");
    s.replace("&nbsp;", " ");
    return s.trimmed();
}

QString stripTags(QString s)
{
    static const QRegularExpression re("<[^>]+>");
    return unescapeHtml(s.replace(re, " ").simplified());
}

QString buildId(const QString &payload)
{
    // payload for manga: "{ULID}/{slug}". For chapter: "{ULID}".
    return QStringLiteral("%1:%2").arg(kSourceKey, payload);
}

bool decodeId(const QString &id, QString *payload)
{
    const QString prefix = QStringLiteral("%1:").arg(kSourceKey);
    if (!id.startsWith(prefix)) return false;
    if (payload) *payload = id.mid(prefix.size());
    return true;
}

QJsonObject makeManga(const QString &ulid, const QString &slug, const QString &title)
{
    QJsonObject attrs;
    attrs.insert("title", QJsonObject{{"en", title}});
    attrs.insert("description", QJsonObject{{"en", QStringLiteral("Weeb Central")}});

    QJsonObject rel;
    rel.insert("type", "cover_art");
    rel.insert("attributes", QJsonObject{{"fileName", QString()}});

    return QJsonObject{
        {"id", buildId(ulid + "/" + slug)},
        {"attributes", attrs},
        {"relationships", QJsonArray{rel}},
    };
}

QJsonObject makeChapter(const QString &chapterUlid, const QString &number,
                        const QString &title)
{
    QJsonObject attrs;
    attrs.insert("chapter", number);
    attrs.insert("title", title);
    attrs.insert("translatedLanguage", "en");
    attrs.insert("externalUrl", QJsonValue());

    QJsonObject rel;
    rel.insert("type", "scanlation_group");
    rel.insert("attributes", QJsonObject{{"name", "Weeb Central"}});

    return QJsonObject{
        {"id", buildId(chapterUlid)},
        {"attributes", attrs},
        {"relationships", QJsonArray{rel}},
    };
}

} // namespace

WeebCentralSource::WeebCentralSource(QObject *parent) : QObject(parent) {}

void WeebCentralSource::getHtml(const QUrl &url,
                                std::function<void(const QString &)> onOk,
                                std::function<void(const QString &)> onErr)
{
    qDebug() << "[WeebCentral] GET" << url.toString();
    QNetworkRequest req(url);
    req.setRawHeader("User-Agent",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36");
    req.setRawHeader("Accept", "text/html");
    // htmx endpoints expect this; harmless for the regular series page.
    req.setRawHeader("HX-Request", "true");
    req.setRawHeader("Referer", kHost);
    req.setAttribute(QNetworkRequest::RedirectPolicyAttribute,
                     QNetworkRequest::NoLessSafeRedirectPolicy);
    // Long-running series (One Piece = ~12 MB chapter list) blow past the
    // default 10 MB decompression cap added in Qt 6.7. Disable the check.
    req.setDecompressedSafetyCheckThreshold(-1);

    auto *reply = m_net.get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply, onOk, onErr]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            const auto msg = reply->errorString();
            qWarning() << "[WeebCentral] error:" << msg;
            if (onErr) onErr(msg);
            emit errorOccurred(msg);
            return;
        }
        onOk(QString::fromUtf8(reply->readAll()));
    });
}

void WeebCentralSource::searchManga(const QString &title)
{
    QUrl url(QStringLiteral("%1/search/data").arg(kHost));
    QUrlQuery q;
    q.addQueryItem("text", QString::fromUtf8(QUrl::toPercentEncoding(title.trimmed())));
    q.addQueryItem("sort", "Best Match");
    q.addQueryItem("order", "Descending");
    q.addQueryItem("official", "Any");
    q.addQueryItem("anime", "Any");
    q.addQueryItem("adult", "Any");
    q.addQueryItem("display_mode", "Full Display");
    url.setQuery(q);

    getHtml(url, [this](const QString &html) {
        QJsonArray out;
        QSet<QString> seen;
        // Each result anchor: href="https://weebcentral.com/series/{ULID}/{slug}"
        // followed (inside the same anchor) by the visible title.
        static const QRegularExpression rx(
            R"RX(<a[^>]*href="https://weebcentral\.com/series/([A-Z0-9]+)/([^"]+)"[^>]*>([\s\S]*?)</a>)RX");
        auto it = rx.globalMatch(html);
        while (it.hasNext()) {
            const auto m = it.next();
            const QString ulid = m.captured(1);
            const QString slug = m.captured(2);
            if (seen.contains(ulid)) continue; // anchors may repeat (cover + title)
            seen.insert(ulid);
            const QString rawInner = m.captured(3);
            QString title = stripTags(rawInner);
            // Trim noise like "View Details" suffix; keep the first non-empty line.
            const auto lines = title.split(QRegularExpression("\\s{2,}|\\n"),
                                           Qt::SkipEmptyParts);
            if (!lines.isEmpty()) title = lines.first().trimmed();
            if (title.isEmpty())
                title = slug;
            out.append(makeManga(ulid, slug, title));
            if (out.size() >= 24) break;
        }
        qDebug() << "[WeebCentral] search results:" << out.size();
        emit searchResults(out);
    }, [this](const QString &) {
        emit searchResults({});
    });
}

void WeebCentralSource::fetchChapters(const QString &mangaId, const QStringList &)
{
    QString payload;
    if (!decodeId(mangaId, &payload)) {
        emit chaptersReceived({});
        return;
    }
    const QString ulid = payload.section('/', 0, 0);
    if (ulid.isEmpty()) {
        emit chaptersReceived({});
        return;
    }

    const QUrl url(QStringLiteral("%1/series/%2/full-chapter-list").arg(kHost, ulid));
    getHtml(url, [this, mangaId](const QString &html) {
        QJsonArray rawDesc; // collected desc order (newest first)

        // Match each chapter anchor along with its inner block (contains
        // "Chapter N" or "Volume N Chapter N" text).
        static const QRegularExpression rx(
            R"RX(<a[^>]*href="https://weebcentral\.com/chapters/([A-Z0-9]+)"[^>]*>([\s\S]*?)</a>)RX");
        static const QRegularExpression numRx(
            R"RX(Chapter\s+(\d+(?:\.\d+)?))RX",
            QRegularExpression::CaseInsensitiveOption);

        QSet<QString> seen;
        auto it = rx.globalMatch(html);
        while (it.hasNext()) {
            const auto m = it.next();
            const QString chId = m.captured(1);
            if (seen.contains(chId)) continue;
            seen.insert(chId);
            const QString inner = m.captured(2);
            const QString text = stripTags(inner);
            QString num;
            const auto nm = numRx.match(text);
            if (nm.hasMatch()) num = nm.captured(1);
            rawDesc.append(makeChapter(chId, num, QString()));
        }

        // The page lists chapters in descending order (newest first). Reverse
        // to match the ascending convention used by SushiScanSource.
        QJsonArray out;
        for (int i = rawDesc.size() - 1; i >= 0; --i)
            out.append(rawDesc.at(i));

        // Backfill chapter numbers using position if extraction failed.
        for (int i = 0; i < out.size(); ++i) {
            auto entry = out.at(i).toObject();
            auto attrs = entry.value("attributes").toObject();
            if (attrs.value("chapter").toString().isEmpty()) {
                attrs.insert("chapter", QString::number(i + 1));
                entry.insert("attributes", attrs);
                out.replace(i, entry);
            }
        }

        qDebug() << "[WeebCentral] chapters loaded:" << out.size() << "for" << mangaId;
        emit chaptersReceived(out);
    }, [this](const QString &) {
        emit chaptersReceived({});
    });
}

void WeebCentralSource::fetchChapterPages(const QString &chapterId)
{
    QString chUlid;
    if (!decodeId(chapterId, &chUlid)) {
        emit chapterPagesReceived(chapterId, {});
        return;
    }

    QUrl url(QStringLiteral("%1/chapters/%2/images").arg(kHost, chUlid));
    QUrlQuery q;
    q.addQueryItem("is_prev", "False");
    q.addQueryItem("current_page", "1");
    q.addQueryItem("reading_style", "long_strip");
    url.setQuery(q);

    getHtml(url, [this, chapterId](const QString &html) {
        QStringList urls;
        QSet<QString> seen;
        static const QRegularExpression rx(
            R"RX(<img[^>]*src="(https?://[^"]+\.(?:png|jpg|jpeg|webp))")RX",
            QRegularExpression::CaseInsensitiveOption);
        auto it = rx.globalMatch(html);
        while (it.hasNext()) {
            const auto m = it.next();
            const QString u = m.captured(1);
            // Filter out site assets (logos, brand icons).
            if (u.contains("/static/") || u.endsWith("brand.png")) continue;
            if (seen.contains(u)) continue;
            seen.insert(u);
            urls << u;
        }
        qDebug() << "[WeebCentral] pages:" << urls.size() << "for" << chapterId;
        emit chapterPagesReceived(chapterId, urls);
    }, [this, chapterId](const QString &) {
        emit chapterPagesReceived(chapterId, {});
    });
}

void WeebCentralSource::fetchSeriesCover(const QString &mangaId)
{
    QString payload;
    if (!decodeId(mangaId, &payload)) {
        emit seriesCoverReceived(mangaId, QString());
        return;
    }
    const QString ulid = payload.section('/', 0, 0);
    const QString slug = payload.section('/', 1);
    if (ulid.isEmpty()) {
        emit seriesCoverReceived(mangaId, QString());
        return;
    }

    const QUrl url(QStringLiteral("%1/series/%2/%3").arg(kHost, ulid, slug));
    getHtml(url, [this, mangaId](const QString &html) {
        QString cover;
        // Prefer Open Graph image, most reliable cover URL on WC.
        static const QRegularExpression ogRx(
            R"RX(<meta[^>]+property="og:image"[^>]+content="([^"]+)")RX");
        auto og = ogRx.match(html);
        if (og.hasMatch()) cover = og.captured(1);
        if (cover.isEmpty()) {
            // Fallback: first <img alt="...cover..."> on the series page.
            static const QRegularExpression imgRx(
                R"RX(<img[^>]+alt="[^"]*[Cc]over[^"]*"[^>]+src="([^"]+)")RX");
            auto im = imgRx.match(html);
            if (im.hasMatch()) cover = im.captured(1);
        }
        qDebug() << "[WeebCentral] cover for" << mangaId << ":" << cover;
        emit seriesCoverReceived(mangaId, cover);
    }, [this, mangaId](const QString &) {
        emit seriesCoverReceived(mangaId, QString());
    });
}
