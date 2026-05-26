/****************************************************************************
** Meta object code from reading C++ file 'sushiscansource.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.11.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/sushiscansource.h"
#include <QtNetwork/QSslError>
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'sushiscansource.h' doesn't include <QObject>."
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
struct qt_meta_tag_ZN15SushiScanSourceE_t {};
} // unnamed namespace

template <> constexpr inline auto SushiScanSource::qt_create_metaobjectdata<qt_meta_tag_ZN15SushiScanSourceE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "SushiScanSource",
        "searchResults",
        "",
        "QJsonArray",
        "results",
        "chaptersReceived",
        "chapters",
        "chapterPagesReceived",
        "chapterId",
        "urls",
        "errorOccurred",
        "message",
        "searchManga",
        "title",
        "fetchChapters",
        "mangaId",
        "languages",
        "fetchChapterPages"
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
        // Signal 'errorOccurred'
        QtMocHelpers::SignalData<void(const QString &)>(10, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 11 },
        }}),
        // Method 'searchManga'
        QtMocHelpers::MethodData<void(const QString &)>(12, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 13 },
        }}),
        // Method 'fetchChapters'
        QtMocHelpers::MethodData<void(const QString &, const QStringList &)>(14, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 15 }, { QMetaType::QStringList, 16 },
        }}),
        // Method 'fetchChapters'
        QtMocHelpers::MethodData<void(const QString &)>(14, 2, QMC::AccessPublic | QMC::MethodCloned, QMetaType::Void, {{
            { QMetaType::QString, 15 },
        }}),
        // Method 'fetchChapterPages'
        QtMocHelpers::MethodData<void(const QString &)>(17, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 8 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<SushiScanSource, qt_meta_tag_ZN15SushiScanSourceE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject SushiScanSource::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN15SushiScanSourceE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN15SushiScanSourceE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN15SushiScanSourceE_t>.metaTypes,
    nullptr
} };

void SushiScanSource::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<SushiScanSource *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->searchResults((*reinterpret_cast<std::add_pointer_t<QJsonArray>>(_a[1]))); break;
        case 1: _t->chaptersReceived((*reinterpret_cast<std::add_pointer_t<QJsonArray>>(_a[1]))); break;
        case 2: _t->chapterPagesReceived((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QStringList>>(_a[2]))); break;
        case 3: _t->errorOccurred((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 4: _t->searchManga((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 5: _t->fetchChapters((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QStringList>>(_a[2]))); break;
        case 6: _t->fetchChapters((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 7: _t->fetchChapterPages((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (SushiScanSource::*)(const QJsonArray & )>(_a, &SushiScanSource::searchResults, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (SushiScanSource::*)(const QJsonArray & )>(_a, &SushiScanSource::chaptersReceived, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (SushiScanSource::*)(const QString & , const QStringList & )>(_a, &SushiScanSource::chapterPagesReceived, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (SushiScanSource::*)(const QString & )>(_a, &SushiScanSource::errorOccurred, 3))
            return;
    }
}

const QMetaObject *SushiScanSource::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *SushiScanSource::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN15SushiScanSourceE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int SushiScanSource::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 8)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 8;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 8)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 8;
    }
    return _id;
}

// SIGNAL 0
void SushiScanSource::searchResults(const QJsonArray & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 0, nullptr, _t1);
}

// SIGNAL 1
void SushiScanSource::chaptersReceived(const QJsonArray & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 1, nullptr, _t1);
}

// SIGNAL 2
void SushiScanSource::chapterPagesReceived(const QString & _t1, const QStringList & _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 2, nullptr, _t1, _t2);
}

// SIGNAL 3
void SushiScanSource::errorOccurred(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 3, nullptr, _t1);
}
QT_WARNING_POP
