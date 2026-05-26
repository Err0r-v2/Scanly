#include "librarystore.h"

#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

LibraryStore::LibraryStore(QObject *parent) : QAbstractListModel(parent)
{
    const auto root = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(root);
    m_path = root + "/library.json";
    load();
}

int LibraryStore::rowCount(const QModelIndex &) const { return m_entries.size(); }

QVariant LibraryStore::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_entries.size()) return {};
    const auto &e = m_entries.at(index.row());
    switch (role) {
    case IdRole:            return e.id;
    case TitleRole:         return e.title;
    case CoverUrlRole:      return e.coverUrl;
    case LastChapterIdRole: return e.lastChapterId;
    case LastPageIndexRole: return e.lastPageIndex;
    }
    return {};
}

QHash<int, QByteArray> LibraryStore::roleNames() const
{
    return {
        {IdRole, "mangaId"},
        {TitleRole, "title"},
        {CoverUrlRole, "coverUrl"},
        {LastChapterIdRole, "lastChapterId"},
        {LastPageIndexRole, "lastPageIndex"},
    };
}

int LibraryStore::indexOf(const QString &id) const
{
    for (int i = 0; i < m_entries.size(); ++i)
        if (m_entries[i].id == id) return i;
    return -1;
}

void LibraryStore::follow(const QString &id, const QString &title, const QString &coverUrl)
{
    if (indexOf(id) >= 0) return;
    beginInsertRows({}, m_entries.size(), m_entries.size());
    m_entries.append({id, title, coverUrl, {}, 0});
    endInsertRows();
    save();
}

void LibraryStore::unfollow(const QString &id)
{
    const int i = indexOf(id);
    if (i < 0) return;
    beginRemoveRows({}, i, i);
    m_entries.removeAt(i);
    endRemoveRows();
    save();
}

bool LibraryStore::isFollowed(const QString &id) const { return indexOf(id) >= 0; }

void LibraryStore::updatePosition(const QString &id, const QString &chapterId, int pageIndex)
{
    const int i = indexOf(id);
    if (i < 0) return;
    m_entries[i].lastChapterId = chapterId;
    m_entries[i].lastPageIndex = pageIndex;
    const auto idx = index(i);
    emit dataChanged(idx, idx, {LastChapterIdRole, LastPageIndexRole});
    save();
}

QVariantMap LibraryStore::get(const QString &id) const
{
    const int i = indexOf(id);
    if (i < 0) return {};
    const auto &e = m_entries[i];
    return {
        {"mangaId", e.id},
        {"title", e.title},
        {"coverUrl", e.coverUrl},
        {"lastChapterId", e.lastChapterId},
        {"lastPageIndex", e.lastPageIndex},
    };
}

QVariantMap LibraryStore::entryAt(int row) const
{
    if (row < 0 || row >= m_entries.size()) return {};
    const auto &e = m_entries[row];
    return {
        {"mangaId", e.id},
        {"title", e.title},
        {"coverUrl", e.coverUrl},
        {"lastChapterId", e.lastChapterId},
        {"lastPageIndex", e.lastPageIndex},
    };
}

void LibraryStore::load()
{
    QFile f(m_path);
    if (!f.open(QIODevice::ReadOnly)) return;
    const auto doc = QJsonDocument::fromJson(f.readAll());
    for (const auto &v : doc.array()) {
        const auto o = v.toObject();
        Entry e;
        e.id = o.value("id").toString();
        e.title = o.value("title").toString();
        e.coverUrl = o.value("coverUrl").toString();
        e.lastChapterId = o.value("lastChapterId").toString();
        e.lastPageIndex = o.value("lastPageIndex").toInt();
        m_entries.append(e);
    }
}

void LibraryStore::save() const
{
    QJsonArray arr;
    for (const auto &e : m_entries) {
        arr.append(QJsonObject{
            {"id", e.id},
            {"title", e.title},
            {"coverUrl", e.coverUrl},
            {"lastChapterId", e.lastChapterId},
            {"lastPageIndex", e.lastPageIndex},
        });
    }
    QFile f(m_path);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate)) return;
    f.write(QJsonDocument(arr).toJson(QJsonDocument::Indented));
}
