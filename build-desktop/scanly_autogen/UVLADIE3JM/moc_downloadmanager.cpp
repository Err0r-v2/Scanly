/****************************************************************************
** Meta object code from reading C++ file 'downloadmanager.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.11.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/downloadmanager.h"
#include <QtNetwork/QSslError>
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'downloadmanager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.11.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN15DownloadManagerE_t {};
} // unnamed namespace

template <> constexpr inline auto DownloadManager::qt_create_metaobjectdata<qt_meta_tag_ZN15DownloadManagerE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "DownloadManager",
        "chapterDownloadStarted",
        "",
        "chapterId",
        "total",
        "chapterDownloadProgress",
        "done",
        "chapterDownloadFinished",
        "chapterDownloadFailed",
        "error",
        "chapterRemoved",
        "manifestChanged",
        "downloadChapter",
        "mangaId",
        "mangaTitle",
        "chapterTitle",
        "chapterNumber",
        "coverUrl",
        "removeChapter",
        "isDownloaded",
        "localPagesFor",
        "totalSizeOnDisk",
        "completedDownloads",
        "QVariantList",
        "activeDownloads",
        "sizeForChapter",
        "coverPathFor",
        "downloadedMangas",
        "downloadedChaptersFor"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'chapterDownloadStarted'
        QtMocHelpers::SignalData<void(const QString &, int)>(1, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 3 }, { QMetaType::Int, 4 },
        }}),
        // Signal 'chapterDownloadProgress'
        QtMocHelpers::SignalData<void(const QString &, int, int)>(5, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 3 }, { QMetaType::Int, 6 }, { QMetaType::Int, 4 },
        }}),
        // Signal 'chapterDownloadFinished'
        QtMocHelpers::SignalData<void(const QString &)>(7, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 3 },
        }}),
        // Signal 'chapterDownloadFailed'
        QtMocHelpers::SignalData<void(const QString &, const QString &)>(8, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 3 }, { QMetaType::QString, 9 },
        }}),
        // Signal 'chapterRemoved'
        QtMocHelpers::SignalData<void(const QString &)>(10, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 3 },
        }}),
        // Signal 'manifestChanged'
        QtMocHelpers::SignalData<void()>(11, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'downloadChapter'
        QtMocHelpers::MethodData<void(const QString &, const QString &, const QString &, const QString &, const QString &, const QString &)>(12, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 3 }, { QMetaType::QString, 13 }, { QMetaType::QString, 14 }, { QMetaType::QString, 15 },
            { QMetaType::QString, 16 }, { QMetaType::QString, 17 },
        }}),
        // Method 'downloadChapter'
        QtMocHelpers::MethodData<void(const QString &, const QString &, const QString &, const QString &, const QString &)>(12, 2, QMC::AccessPublic | QMC::MethodCloned, QMetaType::Void, {{
            { QMetaType::QString, 3 }, { QMetaType::QString, 13 }, { QMetaType::QString, 14 }, { QMetaType::QString, 15 },
            { QMetaType::QString, 16 },
        }}),
        // Method 'downloadChapter'
        QtMocHelpers::MethodData<void(const QString &, const QString &, const QString &, const QString &)>(12, 2, QMC::AccessPublic | QMC::MethodCloned, QMetaType::Void, {{
            { QMetaType::QString, 3 }, { QMetaType::QString, 13 }, { QMetaType::QString, 14 }, { QMetaType::QString, 15 },
        }}),
        // Method 'downloadChapter'
        QtMocHelpers::MethodData<void(const QString &, const QString &, const QString &)>(12, 2, QMC::AccessPublic | QMC::MethodCloned, QMetaType::Void, {{
            { QMetaType::QString, 3 }, { QMetaType::QString, 13 }, { QMetaType::QString, 14 },
        }}),
        // Method 'downloadChapter'
        QtMocHelpers::MethodData<void(const QString &, const QString &)>(12, 2, QMC::AccessPublic | QMC::MethodCloned, QMetaType::Void, {{
            { QMetaType::QString, 3 }, { QMetaType::QString, 13 },
        }}),
        // Method 'downloadChapter'
        QtMocHelpers::MethodData<void(const QString &)>(12, 2, QMC::AccessPublic | QMC::MethodCloned, QMetaType::Void, {{
            { QMetaType::QString, 3 },
        }}),
        // Method 'removeChapter'
        QtMocHelpers::MethodData<void(const QString &)>(18, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 3 },
        }}),
        // Method 'isDownloaded'
        QtMocHelpers::MethodData<bool(const QString &) const>(19, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 3 },
        }}),
        // Method 'localPagesFor'
        QtMocHelpers::MethodData<QStringList(const QString &) const>(20, 2, QMC::AccessPublic, QMetaType::QStringList, {{
            { QMetaType::QString, 3 },
        }}),
        // Method 'totalSizeOnDisk'
        QtMocHelpers::MethodData<qint64() const>(21, 2, QMC::AccessPublic, QMetaType::LongLong),
        // Method 'completedDownloads'
        QtMocHelpers::MethodData<QVariantList() const>(22, 2, QMC::AccessPublic, 0x80000000 | 23),
        // Method 'activeDownloads'
        QtMocHelpers::MethodData<QVariantList() const>(24, 2, QMC::AccessPublic, 0x80000000 | 23),
        // Method 'sizeForChapter'
        QtMocHelpers::MethodData<qint64(const QString &) const>(25, 2, QMC::AccessPublic, QMetaType::LongLong, {{
            { QMetaType::QString, 3 },
        }}),
        // Method 'coverPathFor'
        QtMocHelpers::MethodData<QString(const QString &) const>(26, 2, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 13 },
        }}),
        // Method 'downloadedMangas'
        QtMocHelpers::MethodData<QVariantList() const>(27, 2, QMC::AccessPublic, 0x80000000 | 23),
        // Method 'downloadedChaptersFor'
        QtMocHelpers::MethodData<QVariantList(const QString &) const>(28, 2, QMC::AccessPublic, 0x80000000 | 23, {{
            { QMetaType::QString, 13 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<DownloadManager, qt_meta_tag_ZN15DownloadManagerE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject DownloadManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN15DownloadManagerE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN15DownloadManagerE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN15DownloadManagerE_t>.metaTypes,
    nullptr
} };

void DownloadManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<DownloadManager *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->chapterDownloadStarted((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2]))); break;
        case 1: _t->chapterDownloadProgress((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<int>>(_a[3]))); break;
        case 2: _t->chapterDownloadFinished((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 3: _t->chapterDownloadFailed((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2]))); break;
        case 4: _t->chapterRemoved((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 5: _t->manifestChanged(); break;
        case 6: _t->downloadChapter((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[4])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[5])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[6]))); break;
        case 7: _t->downloadChapter((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[4])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[5]))); break;
        case 8: _t->downloadChapter((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[4]))); break;
        case 9: _t->downloadChapter((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3]))); break;
        case 10: _t->downloadChapter((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2]))); break;
        case 11: _t->downloadChapter((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 12: _t->removeChapter((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 13: { bool _r = _t->isDownloaded((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 14: { QStringList _r = _t->localPagesFor((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast<QStringList*>(_a[0]) = std::move(_r); }  break;
        case 15: { qint64 _r = _t->totalSizeOnDisk();
            if (_a[0]) *reinterpret_cast<qint64*>(_a[0]) = std::move(_r); }  break;
        case 16: { QVariantList _r = _t->completedDownloads();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 17: { QVariantList _r = _t->activeDownloads();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 18: { qint64 _r = _t->sizeForChapter((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast<qint64*>(_a[0]) = std::move(_r); }  break;
        case 19: { QString _r = _t->coverPathFor((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 20: { QVariantList _r = _t->downloadedMangas();
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 21: { QVariantList _r = _t->downloadedChaptersFor((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast<QVariantList*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (DownloadManager::*)(const QString & , int )>(_a, &DownloadManager::chapterDownloadStarted, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (DownloadManager::*)(const QString & , int , int )>(_a, &DownloadManager::chapterDownloadProgress, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (DownloadManager::*)(const QString & )>(_a, &DownloadManager::chapterDownloadFinished, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (DownloadManager::*)(const QString & , const QString & )>(_a, &DownloadManager::chapterDownloadFailed, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (DownloadManager::*)(const QString & )>(_a, &DownloadManager::chapterRemoved, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (DownloadManager::*)()>(_a, &DownloadManager::manifestChanged, 5))
            return;
    }
}

const QMetaObject *DownloadManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *DownloadManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN15DownloadManagerE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int DownloadManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 22)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 22;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 22)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 22;
    }
    return _id;
}

// SIGNAL 0
void DownloadManager::chapterDownloadStarted(const QString & _t1, int _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 0, nullptr, _t1, _t2);
}

// SIGNAL 1
void DownloadManager::chapterDownloadProgress(const QString & _t1, int _t2, int _t3)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 1, nullptr, _t1, _t2, _t3);
}

// SIGNAL 2
void DownloadManager::chapterDownloadFinished(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 2, nullptr, _t1);
}

// SIGNAL 3
void DownloadManager::chapterDownloadFailed(const QString & _t1, const QString & _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 3, nullptr, _t1, _t2);
}

// SIGNAL 4
void DownloadManager::chapterRemoved(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 4, nullptr, _t1);
}

// SIGNAL 5
void DownloadManager::manifestChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}
QT_WARNING_POP
