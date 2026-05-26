#include "mangasourcerouter.h"

#include "sushiscansource.h"
#include "weebcentralsource.h"
#include "settingsstore.h"

#include <QDebug>

namespace {
constexpr const char *kScanMirrorKey  = "scanmirror";
constexpr const char *kWeebCentralKey = "weebcentral";
}

MangaSourceRouter::MangaSourceRouter(SushiScanSource *fr,
                                     WeebCentralSource *en,
                                     SettingsStore *settings,
                                     QObject *parent)
    : QObject(parent), m_fr(fr), m_en(en), m_settings(settings)
{
    // Re-emit child signals for chapters / chapter pages / errors.
    connect(m_fr, &SushiScanSource::chaptersReceived,
            this, &MangaSourceRouter::chaptersReceived);
    connect(m_en, &WeebCentralSource::chaptersReceived,
            this, &MangaSourceRouter::chaptersReceived);

    connect(m_fr, &SushiScanSource::chapterPagesReceived,
            this, &MangaSourceRouter::chapterPagesReceived);
    connect(m_en, &WeebCentralSource::chapterPagesReceived,
            this, &MangaSourceRouter::chapterPagesReceived);

    connect(m_fr, &SushiScanSource::errorOccurred,
            this, &MangaSourceRouter::errorOccurred);
    connect(m_en, &WeebCentralSource::errorOccurred,
            this, &MangaSourceRouter::errorOccurred);

    // Search: accumulate before forwarding.
    connect(m_fr, &SushiScanSource::searchResults,
            this, &MangaSourceRouter::onChildSearchResults);
    connect(m_en, &WeebCentralSource::searchResults,
            this, &MangaSourceRouter::onChildSearchResults);

    // WeebCentral cover fallback.
    connect(m_en, &WeebCentralSource::seriesCoverReceived,
            this, [this](const QString &mid, const QString &url) {
        m_fallbackInFlight.remove(mid);
        m_fallbackCovers.insert(mid, url);
        emit fallbackCoverReceived(mid, url);
    });
}

bool MangaSourceRouter::isWeebCentralId(const QString &id)
{
    return id.startsWith(QLatin1String("weebcentral:"));
}

void MangaSourceRouter::searchManga(const QString &title)
{
    m_searchBuffer = {};
    m_searchPending = 0;
    m_searchActive  = true;

    const QStringList enabled = m_settings
        ? m_settings->enabledSources()
        : QStringList{kScanMirrorKey, kWeebCentralKey};

    if (enabled.contains(kScanMirrorKey)) {
        ++m_searchPending;
        m_fr->searchManga(title);
    }
    if (enabled.contains(kWeebCentralKey)) {
        ++m_searchPending;
        m_en->searchManga(title);
    }

    if (m_searchPending == 0) {
        m_searchActive = false;
        emit searchResults({});
    }
}

void MangaSourceRouter::onChildSearchResults(const QJsonArray &results)
{
    if (!m_searchActive) return;
    for (const auto &v : results) m_searchBuffer.append(v);
    if (m_searchPending > 0) --m_searchPending;
    finalizeSearchIfDone();
}

void MangaSourceRouter::finalizeSearchIfDone()
{
    if (m_searchPending > 0) return;
    m_searchActive = false;
    qDebug() << "[Router] search merged:" << m_searchBuffer.size();
    emit searchResults(m_searchBuffer);
    m_searchBuffer = {};
}

void MangaSourceRouter::fetchChapters(const QString &mangaId, const QStringList &languages)
{
    if (isWeebCentralId(mangaId))
        m_en->fetchChapters(mangaId, languages);
    else
        m_fr->fetchChapters(mangaId, languages);
}

void MangaSourceRouter::fetchChapterPages(const QString &chapterId)
{
    if (isWeebCentralId(chapterId))
        m_en->fetchChapterPages(chapterId);
    else
        m_fr->fetchChapterPages(chapterId);
}

QString MangaSourceRouter::languageForId(const QString &id) const
{
    return isWeebCentralId(id) ? QStringLiteral("English")
                               : QStringLiteral("French");
}

void MangaSourceRouter::fetchFallbackCover(const QString &mangaId)
{
    if (!isWeebCentralId(mangaId)) return; // FR sources already ship a cover
    if (m_fallbackCovers.contains(mangaId)) {
        emit fallbackCoverReceived(mangaId, m_fallbackCovers.value(mangaId));
        return;
    }
    if (m_fallbackInFlight.contains(mangaId)) return;
    m_fallbackInFlight.insert(mangaId);
    m_en->fetchSeriesCover(mangaId);
}

QString MangaSourceRouter::fallbackCoverFor(const QString &mangaId) const
{
    return m_fallbackCovers.value(mangaId);
}
