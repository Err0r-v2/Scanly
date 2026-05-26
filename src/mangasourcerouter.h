#pragma once

#include <QObject>
#include <QJsonArray>
#include <QHash>
#include <QString>
#include <QStringList>

class SushiScanSource;
class WeebCentralSource;
class SettingsStore;

// Facade that multiplexes multiple manga sources behind a single QQmlContext
// property (`source`). Routes per-ID operations by ID prefix; fans search
// across all enabled sources and accumulates their results.
class MangaSourceRouter : public QObject
{
    Q_OBJECT
public:
    MangaSourceRouter(SushiScanSource *fr,
                      WeebCentralSource *en,
                      SettingsStore *settings,
                      QObject *parent = nullptr);

    Q_INVOKABLE void searchManga(const QString &title);
    Q_INVOKABLE void fetchChapters(const QString &mangaId,
                                   const QStringList &languages = {});
    Q_INVOKABLE void fetchChapterPages(const QString &chapterId);

    Q_INVOKABLE QString languageForId(const QString &id) const;

    // Fallback cover : called from MangaPage when MangaDex meta misses.
    // Returns cached URL (or empty) immediately and emits
    // fallbackCoverReceived when the underlying fetch resolves.
    Q_INVOKABLE void fetchFallbackCover(const QString &mangaId);
    Q_INVOKABLE QString fallbackCoverFor(const QString &mangaId) const;

signals:
    void searchResults(const QJsonArray &results);
    void chaptersReceived(const QJsonArray &chapters);
    void chapterPagesReceived(const QString &chapterId, const QStringList &urls);
    void fallbackCoverReceived(const QString &mangaId, const QString &coverUrl);
    void errorOccurred(const QString &message);

private:
    SushiScanSource    *m_fr      = nullptr;
    WeebCentralSource  *m_en      = nullptr;
    SettingsStore      *m_settings = nullptr;

    // Search accumulator state (one search at a time).
    QJsonArray  m_searchBuffer;
    int         m_searchPending  = 0;
    bool        m_searchActive   = false;

    QHash<QString, QString> m_fallbackCovers;
    QSet<QString>           m_fallbackInFlight;

    static bool isWeebCentralId(const QString &id);
    void onChildSearchResults(const QJsonArray &results);
    void finalizeSearchIfDone();
};
