#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QJsonArray>
#include <QStringList>
#include <QUrl>
#include <functional>

// Scrapes weebcentral.com (English manga). Same signal contract as
// SushiScanSource so the MangaSourceRouter can multiplex them.
class WeebCentralSource : public QObject
{
    Q_OBJECT
public:
    explicit WeebCentralSource(QObject *parent = nullptr);

    Q_INVOKABLE void searchManga(const QString &title);
    Q_INVOKABLE void fetchChapters(const QString &mangaId,
                                   const QStringList &languages = {"en"});
    Q_INVOKABLE void fetchChapterPages(const QString &chapterId);
    Q_INVOKABLE void fetchSeriesCover(const QString &mangaId);

signals:
    void searchResults(const QJsonArray &results);
    void chaptersReceived(const QJsonArray &chapters);
    void chapterPagesReceived(const QString &chapterId, const QStringList &urls);
    void seriesCoverReceived(const QString &mangaId, const QString &coverUrl);
    void errorOccurred(const QString &message);

private:
    QNetworkAccessManager m_net;

    void getHtml(const QUrl &url,
                 std::function<void(const QString &)> onOk,
                 std::function<void(const QString &)> onErr = {});
};
