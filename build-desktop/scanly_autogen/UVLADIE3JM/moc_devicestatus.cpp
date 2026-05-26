/****************************************************************************
** Meta object code from reading C++ file 'devicestatus.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.11.1)
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
struct qt_meta_tag_ZN12DeviceStatusE_t {};
} // unnamed namespace

template <> constexpr inline auto DeviceStatus::qt_create_metaobjectdata<qt_meta_tag_ZN12DeviceStatusE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
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
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'changed'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'tick'
        QtMocHelpers::SignalData<void()>(3, 2, QMC::AccessPublic, QMetaType::Void),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'batteryPercent'
        QtMocHelpers::PropertyData<int>(4, QMetaType::Int, QMC::DefaultPropertyFlags, 0),
        // property 'batteryCharging'
        QtMocHelpers::PropertyData<bool>(5, QMetaType::Bool, QMC::DefaultPropertyFlags, 0),
        // property 'online'
        QtMocHelpers::PropertyData<bool>(6, QMetaType::Bool, QMC::DefaultPropertyFlags, 0),
        // property 'landscape'
        QtMocHelpers::PropertyData<bool>(7, QMetaType::Bool, QMC::DefaultPropertyFlags, 0),
        // property 'rotationAngle'
        QtMocHelpers::PropertyData<int>(8, QMetaType::Int, QMC::DefaultPropertyFlags, 0),
        // property 'storageBytesTotal'
        QtMocHelpers::PropertyData<qint64>(9, QMetaType::LongLong, QMC::DefaultPropertyFlags, 0),
        // property 'storageBytesFree'
        QtMocHelpers::PropertyData<qint64>(10, QMetaType::LongLong, QMC::DefaultPropertyFlags, 0),
        // property 'storageBytesUsed'
        QtMocHelpers::PropertyData<qint64>(11, QMetaType::LongLong, QMC::DefaultPropertyFlags, 0),
        // property 'currentTime'
        QtMocHelpers::PropertyData<QString>(12, QMetaType::QString, QMC::DefaultPropertyFlags, 1),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<DeviceStatus, qt_meta_tag_ZN12DeviceStatusE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject DeviceStatus::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN12DeviceStatusE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN12DeviceStatusE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN12DeviceStatusE_t>.metaTypes,
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
        if (QtMocHelpers::indexOfMethod<void (DeviceStatus::*)()>(_a, &DeviceStatus::changed, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (DeviceStatus::*)()>(_a, &DeviceStatus::tick, 1))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<int*>(_v) = _t->batteryPercent(); break;
        case 1: *reinterpret_cast<bool*>(_v) = _t->batteryCharging(); break;
        case 2: *reinterpret_cast<bool*>(_v) = _t->online(); break;
        case 3: *reinterpret_cast<bool*>(_v) = _t->landscape(); break;
        case 4: *reinterpret_cast<int*>(_v) = _t->rotationAngle(); break;
        case 5: *reinterpret_cast<qint64*>(_v) = _t->storageBytesTotal(); break;
        case 6: *reinterpret_cast<qint64*>(_v) = _t->storageBytesFree(); break;
        case 7: *reinterpret_cast<qint64*>(_v) = _t->storageBytesUsed(); break;
        case 8: *reinterpret_cast<QString*>(_v) = _t->currentTime(); break;
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
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN12DeviceStatusE_t>.strings))
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
