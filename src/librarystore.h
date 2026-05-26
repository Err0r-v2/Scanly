#pragma once

#include <QAbstractListModel>

class LibraryStore : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        TitleRole,
        CoverUrlRole,
        LastChapterIdRole,
        LastPageIndexRole,
    };

    struct Entry {
        QString id;
        QString title;
        QString coverUrl;
        QString lastChapterId;
        int lastPageIndex = 0;
    };

    explicit LibraryStore(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void follow(const QString &id, const QString &title, const QString &coverUrl);
    Q_INVOKABLE void unfollow(const QString &id);
    Q_INVOKABLE bool isFollowed(const QString &id) const;
    Q_INVOKABLE void updatePosition(const QString &id, const QString &chapterId, int pageIndex);
    Q_INVOKABLE QVariantMap get(const QString &id) const;
    Q_INVOKABLE QVariantMap entryAt(int row) const;
    Q_INVOKABLE QVariantMap firstEntry() const { return entryAt(0); }

private:
    QList<Entry> m_entries;
    QString m_path;

    int indexOf(const QString &id) const;
    void load();
    void save() const;
};
