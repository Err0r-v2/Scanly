#include "searchmodel.h"

#include <QJsonObject>

SearchModel::SearchModel(QObject *parent) : QAbstractListModel(parent) {}

int SearchModel::rowCount(const QModelIndex &) const { return m_entries.size(); }

QVariant SearchModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_entries.size())
        return {};
    const auto &e = m_entries.at(index.row());
    switch (role) {
    case IdRole:          return e.id;
    case TitleRole:       return e.title;
    case CoverUrlRole:    return e.coverUrl;
    case DescriptionRole: return e.description;
    }
    return {};
}

QHash<int, QByteArray> SearchModel::roleNames() const
{
    return {
        {IdRole, "mangaId"},
        {TitleRole, "title"},
        {CoverUrlRole, "coverUrl"},
        {DescriptionRole, "description"},
    };
}

QString SearchModel::pickTitle(const QJsonObject &attrs)
{
    const auto title = attrs.value("title").toObject();
    for (const auto &lang : { "en", "ja-ro", "ja", "fr" }) {
        const auto v = title.value(lang).toString();
        if (!v.isEmpty()) return v;
    }
    for (const auto &v : title)
        if (v.isString() && !v.toString().isEmpty()) return v.toString();
    return QStringLiteral("(no title)");
}

QString SearchModel::buildCoverUrl(const QString &mangaId, const QJsonArray &relationships)
{
    for (const auto &rel : relationships) {
        const auto obj = rel.toObject();
        if (obj.value("type").toString() != "cover_art") continue;
        const auto fileName = obj.value("attributes").toObject().value("fileName").toString();
        if (fileName.isEmpty()) continue;
        if (fileName.startsWith("http://") || fileName.startsWith("https://"))
            return fileName;
        return QString("https://uploads.mangadex.org/covers/%1/%2.512.jpg")
            .arg(mangaId, fileName);
    }
    return {};
}

void SearchModel::updateFrom(const QJsonArray &results)
{
    beginResetModel();
    m_entries.clear();
    for (const auto &v : results) {
        const auto obj = v.toObject();
        const auto attrs = obj.value("attributes").toObject();
        const auto descriptions = attrs.value("description").toObject();
        auto desc = descriptions.value("fr").toString();
        if (desc.isEmpty())
            desc = descriptions.value("en").toString();
        Entry e;
        e.id = obj.value("id").toString();
        e.title = pickTitle(attrs);
        e.coverUrl = buildCoverUrl(e.id, obj.value("relationships").toArray());
        e.description = desc;
        m_entries.append(e);
    }
    endResetModel();
}
