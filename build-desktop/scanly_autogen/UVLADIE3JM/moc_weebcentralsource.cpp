/****************************************************************************
** Meta object code from reading C++ file 'weebcentralsource.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.11.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/weebcentralsource.h"
#include <QtNetwork/QSslError>
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'weebcentralsource.h' doesn't include <QObject>."
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
struct qt_meta_tag_ZN17WeebCentralSourceE_t {};
} // unnamed namespace

template <> constexpr inline auto WeebCentralSource::qt_create_metaobjectdata<qt_meta_tag_ZN17WeebCentralSourceE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "WeebCentralSource",
        "searchResults",
        "",
        "QJsonArray",
        "results",
        "chaptersReceived",
        "chapters",
        "chapterPagesReceived",
        "chapterId",
        "urls",
        "seriesCoverReceived",
        "mangaId",
        "coverUrl",
        "errorOccurred",
        "message",
        "searchManga",
        "title",
        "fetchChapters",
        "languages",
        "fetchChapterPages",
        "fetchSeriesCover"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'searchResults'
        QtMocHelpers::SignalData<void(const QJsonArray &)>(1, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 3, 4 },
        }}),
        // Signal 'chaptersReceived'
        QtMocHelpers::SignalData<void(const QJsonArray &)>(5, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 3, 6 },
        }}),
        // Signal 'chapterPagesReceived'
        QtMocHelpers::SignalData<void(const QString &, const QStringList &)>(7, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 8 }, { QMetaType::QStringList, 9 },
        }}),
        // Signal 'seriesCoverReceived'
        QtMocHelpers::SignalData<void(const QString &, const QString &)>(10, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 11 }, { QMetaType::QString, 12 },
        }}),
        // Signal 'errorOccurred'
        QtMocHelpers::SignalData<void(const QString &)>(13, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 14 },
        }}),
        // Method 'searchManga'
        QtMocHelpers::MethodData<void(const QString &)>(15, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 16 },
        }}),
        // Method 'fetchChapters'
        QtMocHelpers::MethodData<void(const QString &, const QStringList &)>(17, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 11 }, { QMetaType::QStringList, 18 },
        }}),
        // Method 'fetchChapters'
        QtMocHelpers::MethodData<void(const QString &)>(17, 2, QMC::AccessPublic | QMC::MethodCloned, QMetaType::Void, {{
            { QMetaType::QString, 11 },
        }}),
        // Method 'fetchChapterPages'
        QtMocHelpers::MethodData<void(const QString &)>(19, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 8 },
        }}),
        // Method 'fetchSeriesCover'
        QtMocHelpers::MethodData<void(const QString &)>(20, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 11 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<WeebCentralSource, qt_meta_tag_ZN17WeebCentralSourceE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject WeebCentralSource::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN17WeebCentralSourceE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN17WeebCentralSourceE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN17WeebCentralSourceE_t>.metaTypes,
    nullptr
} };

void WeebCentralSource::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<WeebCentralSource *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->searchResults((*reinterpret_cast<std::add_pointer_t<QJsonArray>>(_a[1]))); break;
        case 1: _t->chaptersReceived((*reinterpret_cast<std::add_pointer_t<QJsonArray>>(_a[1]))); break;
        case 2: _t->chapterPagesReceived((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QStringList>>(_a[2]))); break;
        case 3: _t->seriesCoverReceived((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2]))); break;
        case 4: _t->errorOccurred((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 5: _t->searchManga((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 6: _t->fetchChapters((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QStringList>>(_a[2]))); break;
        case 7: _t->fetchChapters((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 8: _t->fetchChapterPages((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 9: _t->fetchSeriesCover((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (WeebCentralSource::*)(const QJsonArray & )>(_a, &WeebCentralSource::searchResults, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (WeebCentralSource::*)(const QJsonArray & )>(_a, &WeebCentralSource::chaptersReceived, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (WeebCentralSource::*)(const QString & , const QStringList & )>(_a, &WeebCentralSource::chapterPagesReceived, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (WeebCentralSource::*)(const QString & , const QString & )>(_a, &WeebCentralSource::seriesCoverReceived, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (WeebCentralSource::*)(const QString & )>(_a, &WeebCentralSource::errorOccurred, 4))
            return;
    }
}

const QMetaObject *WeebCentralSource::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *WeebCentralSource::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN17WeebCentralSourceE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int WeebCentralSource::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 10)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 10;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 10)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 10;
    }
    return _id;
}

// SIGNAL 0
void WeebCentralSource::searchResults(const QJsonArray & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 0, nullptr, _t1);
}

// SIGNAL 1
void WeebCentralSource::chaptersReceived(const QJsonArray & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 1, nullptr, _t1);
}

// SIGNAL 2
void WeebCentralSource::chapterPagesReceived(const QString & _t1, const QStringList & _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 2, nullptr, _t1, _t2);
}

// SIGNAL 3
void WeebCentralSource::seriesCoverReceived(const QString & _t1, const QString & _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 3, nullptr, _t1, _t2);
}

// SIGNAL 4
void WeebCentralSource::errorOccurred(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 4, nullptr, _t1);
}
QT_WARNING_POP
