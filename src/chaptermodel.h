#pragma once

#include <QAbstractListModel>
#include <QStringList>

class ChapterModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles { UrlRole = Qt::UserRole + 1, IndexRole };

    explicit ChapterModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void setPages(const QString &baseUrl, const QString &hash, const QStringList &pages);

private:
    QStringList m_urls;
};
