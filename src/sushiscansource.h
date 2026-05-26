#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QJsonArray>
#include <QStringList>

// Scrapes static auto-index scan mirrors used by SushiScan.
class SushiScanSource : public QObject
{
    Q_OBJECT
public:
    explicit SushiScanSource(QObject *parent = nullptr);

    Q_INVOKABLE void searchManga(const QString &title);
    Q_INVOKABLE void fetchChapters(const QString &mangaId,
                                   const QStringList &languages = {"fr"});
    Q_INVOKABLE void fetchChapterPages(const QString &chapterId);

signals:
    void searchResults(const QJsonArray &results);
    void chaptersReceived(const QJsonArray &chapters);
    void chapterPagesReceived(const QString &chapterId, const QStringList &urls);
    void errorOccurred(const QString &message);

private:
    QNetworkAccessManager m_net;

    void getHtml(const QUrl &url,
                 std::function<void(const QString &)> onOk,
                 std::function<void(const QString &)> onErr = {});
};
