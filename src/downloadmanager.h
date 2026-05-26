#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QJsonObject>
#include <QHash>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>

class MangaSourceRouter;

class DownloadManager : public QObject
{
    Q_OBJECT
public:
    explicit DownloadManager(MangaSourceRouter *client, QObject *parent = nullptr);

    Q_INVOKABLE void downloadChapter(const QString &chapterId,
                                     const QString &mangaId = {},
                                     const QString &mangaTitle = {},
                                     const QString &chapterTitle = {},
                                     const QString &chapterNumber = {},
                                     const QString &coverUrl = {});
    Q_INVOKABLE void removeChapter(const QString &chapterId);
    Q_INVOKABLE bool isDownloaded(const QString &chapterId) const;
    Q_INVOKABLE QStringList localPagesFor(const QString &chapterId) const;
    Q_INVOKABLE qint64 totalSizeOnDisk() const;
    Q_INVOKABLE QVariantList completedDownloads() const;
    Q_INVOKABLE QVariantList activeDownloads() const;
    Q_INVOKABLE qint64 sizeForChapter(const QString &chapterId) const;
    Q_INVOKABLE QString coverPathFor(const QString &mangaId) const;
    Q_INVOKABLE QVariantList downloadedMangas() const;
    Q_INVOKABLE QVariantList downloadedChaptersFor(const QString &mangaId) const;

signals:
    void chapterDownloadStarted(const QString &chapterId, int total);
    void chapterDownloadProgress(const QString &chapterId, int done, int total);
    void chapterDownloadFinished(const QString &chapterId);
    void chapterDownloadFailed(const QString &chapterId, const QString &error);
    void chapterRemoved(const QString &chapterId);
    void manifestChanged();

private:
    struct Job {
        QString chapterId;
        QString mangaId;
        QString mangaTitle;
        QString chapterTitle;
        QString chapterNumber;
        QString coverUrl;
        QStringList remoteUrls;
        QVector<QString> localPaths;
        int dispatched = 0;
        int inFlight = 0;
        int completed = 0;
        bool failed = false;
    };

    MangaSourceRouter *m_client;
    QNetworkAccessManager m_net;
    QHash<QString, Job> m_jobs;
    QString m_root;
    QString m_coversRoot;
    QJsonObject m_manifest;

    void onPages(const QString &chapterId, const QStringList &urls);
    void pumpJob(const QString &chapterId);
    void dispatchPage(const QString &chapterId, int index);
    void finalizeJob(const QString &chapterId);
    bool saveImage(const QByteArray &data, const QString &outPath);
    void ensureCoverDownloaded(const QString &mangaId, const QString &coverUrl);
    QString coverFilePath(const QString &mangaId) const;
    void loadManifest();
    void saveManifest();
};
