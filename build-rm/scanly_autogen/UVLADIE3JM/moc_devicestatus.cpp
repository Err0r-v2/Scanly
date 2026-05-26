/****************************************************************************
** Meta object code from reading C++ file 'devicestatus.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.8.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/devicestatus.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'devicestatus.h' doesn't include <QObject>."
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
struct qt_meta_tag_ZN12DeviceStatusE_t {};
} // unnamed namespace


#ifdef QT_MOC_HAS_STRINGDATA
static constexpr auto qt_meta_stringdata_ZN12DeviceStatusE = QtMocHelpers::stringData(
    "DeviceStatus",
    "changed",
    "",
    "tick",
    "batteryPercent",
    "batteryCharging",
    "online",
    "landscape",
    "rotationAngle",
    "storageBytesTotal",
    "storageBytesFree",
    "storageBytesUsed",
    "currentTime"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA

Q_CONSTINIT static const uint qt_meta_data_ZN12DeviceStatusE[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
       2,   14, // methods
       9,   28, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,   26,    2, 0x06,   10 /* Public */,
       3,    0,   27,    2, 0x06,   11 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,

 // properties: name, type, flags, notifyId, revision
       4, QMetaType::Int, 0x00015001, uint(0), 0,
       5, QMetaType::Bool, 0x00015001, uint(0), 0,
       6, QMetaType::Bool, 0x00015001, uint(0), 0,
       7, QMetaType::Bool, 0x00015001, uint(0), 0,
       8, QMetaType::Int, 0x00015001, uint(0), 0,
       9, QMetaType::LongLong, 0x00015001, uint(0), 0,
      10, QMetaType::LongLong, 0x00015001, uint(0), 0,
      11, QMetaType::LongLong, 0x00015001, uint(0), 0,
      12, QMetaType::QString, 0x00015001, uint(1), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject DeviceStatus::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_ZN12DeviceStatusE.offsetsAndSizes,
    qt_meta_data_ZN12DeviceStatusE,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_tag_ZN12DeviceStatusE_t,
        // property 'batteryPercent'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'batteryCharging'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'online'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'landscape'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'rotationAngle'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'storageBytesTotal'
        QtPrivate::TypeAndForceComplete<qint64, std::true_type>,
        // property 'storageBytesFree'
        QtPrivate::TypeAndForceComplete<qint64, std::true_type>,
        // property 'storageBytesUsed'
        QtPrivate::TypeAndForceComplete<qint64, std::true_type>,
        // property 'currentTime'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<DeviceStatus, std::true_type>,
        // method 'changed'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'tick'
        QtPrivate::TypeAndForceComplete<void, std::false_type>
    >,
    nullptr
} };

void DeviceStatus::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<DeviceStatus *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->changed(); break;
        case 1: _t->tick(); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _q_method_type = void (DeviceStatus::*)();
            if (_q_method_type _q_method = &DeviceStatus::changed; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _q_method_type = void (DeviceStatus::*)();
            if (_q_method_type _q_method = &DeviceStatus::tick; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< int*>(_v) = _t->batteryPercent(); break;
        case 1: *reinterpret_cast< bool*>(_v) = _t->batteryCharging(); break;
        case 2: *reinterpret_cast< bool*>(_v) = _t->online(); break;
        case 3: *reinterpret_cast< bool*>(_v) = _t->landscape(); break;
        case 4: *reinterpret_cast< int*>(_v) = _t->rotationAngle(); break;
        case 5: *reinterpret_cast< qint64*>(_v) = _t->storageBytesTotal(); break;
        case 6: *reinterpret_cast< qint64*>(_v) = _t->storageBytesFree(); break;
        case 7: *reinterpret_cast< qint64*>(_v) = _t->storageBytesUsed(); break;
        case 8: *reinterpret_cast< QString*>(_v) = _t->currentTime(); break;
        default: break;
        }
    }
}

const QMetaObject *DeviceStatus::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *DeviceStatus::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_ZN12DeviceStatusE.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int DeviceStatus::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 2)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 2;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 2)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 2;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 9;
    }
    return _id;
}

// SIGNAL 0
void DeviceStatus::changed()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void DeviceStatus::tick()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}
QT_WARNING_POP
