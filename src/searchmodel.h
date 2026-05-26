#pragma once

#include <QAbstractListModel>
#include <QJsonArray>

class SearchModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        TitleRole,
        CoverUrlRole,
        DescriptionRole,
    };

    struct Entry {
        QString id;
        QString title;
        QString coverUrl;
        QString description;
    };

    explicit SearchModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

public slots:
    void updateFrom(const QJsonArray &results);

private:
    QList<Entry> m_entries;

    static QString pickTitle(const QJsonObject &attrs);
    static QString buildCoverUrl(const QString &mangaId, const QJsonArray &relationships);
};
