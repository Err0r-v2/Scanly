/****************************************************************************
** Meta object code from reading C++ file 'epaperhints.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.8.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/epaperhints.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'epaperhints.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.8.2. It"
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
struct qt_meta_tag_ZN11EpaperHintsE_t {};
} // unnamed namespace


#ifdef QT_MOC_HAS_STRINGDATA
static constexpr auto qt_meta_stringdata_ZN11EpaperHintsE = QtMocHelpers::stringData(
    "EpaperHints",
    "setAppLoadRefreshMode",
    "",
    "mode",
    "resetAppLoadRefreshMode",
    "clearGhosting",
    "partialRefresh",
    "fullRefresh"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA

Q_CONSTINIT static const uint qt_meta_data_ZN11EpaperHintsE[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
       5,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
       1,    1,   44,    2, 0x02,    1 /* Public */,
       4,    0,   47,    2, 0x02,    3 /* Public */,
       5,    0,   48,    2, 0x02,    4 /* Public */,
       6,    0,   49,    2, 0x02,    5 /* Public */,
       7,    0,   50,    2, 0x02,    6 /* Public */,

 // methods: parameters
    QMetaType::Void, QMetaType::QString,    3,
    QMetaType::Void,
    QMetaType::Bool,
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

Q_CONSTINIT const QMetaObject EpaperHints::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_ZN11EpaperHintsE.offsetsAndSizes,
    qt_meta_data_ZN11EpaperHintsE,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_tag_ZN11EpaperHintsE_t,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<EpaperHints, std::true_type>,
        // method 'setAppLoadRefreshMode'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'resetAppLoadRefreshMode'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'clearGhosting'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        // method 'partialRefresh'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'fullRefresh'
        QtPrivate::TypeAndForceComplete<void, std::false_type>
    >,
    nullptr
} };

void EpaperHints::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<EpaperHints *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->setAppLoadRefreshMode((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 1: _t->resetAppLoadRefreshMode(); break;
        case 2: { bool _r = _t->clearGhosting();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 3: _t->partialRefresh(); break;
        case 4: _t->fullRefresh(); break;
        default: ;
        }
    }
}

const QMetaObject *EpaperHints::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *EpaperHints::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_ZN11EpaperHintsE.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int EpaperHints::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 5)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 5)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 5;
    }
    return _id;
}
QT_WARNING_POP
