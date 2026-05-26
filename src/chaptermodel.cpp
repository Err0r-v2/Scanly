#include "chaptermodel.h"

ChapterModel::ChapterModel(QObject *parent) : QAbstractListModel(parent) {}

int ChapterModel::rowCount(const QModelIndex &) const { return m_urls.size(); }

QVariant ChapterModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_urls.size())
        return {};
    switch (role) {
    case UrlRole:   return m_urls.at(index.row());
    case IndexRole: return index.row();
    }
    return {};
}

QHash<int, QByteArray> ChapterModel::roleNames() const
{
    return { {UrlRole, "url"}, {IndexRole, "pageIndex"} };
}

void ChapterModel::setPages(const QString &baseUrl, const QString &hash, const QStringList &pages)
{
    beginResetModel();
    m_urls.clear();
    for (const auto &p : pages)
        m_urls << QString("%1/data/%2/%3").arg(baseUrl, hash, p);
    endResetModel();
}
