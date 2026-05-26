/****************************************************************************
** Meta object code from reading C++ file 'settingsstore.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.11.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/settingsstore.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'settingsstore.h' doesn't include <QObject>."
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
struct qt_meta_tag_ZN13SettingsStoreE_t {};
} // unnamed namespace

template <> constexpr inline auto SettingsStore::qt_create_metaobjectdata<qt_meta_tag_ZN13SettingsStoreE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "SettingsStore",
        "blackAndWhiteChanged",
        "",
        "autoAdvanceChapterChanged",
        "forceScreenModeChanged",
        "screenModeChanged",
        "ghostCleanIntervalChanged",
        "preferredLanguagesChanged",
        "offlineModeChanged",
        "enabledSourcesChanged",
        "keyboardLayoutChanged",
        "isSourceEnabled",
        "key",
        "toggleSource",
        "toggleKeyboardLayout",
        "toggleLanguage",
        "code",
        "blackAndWhite",
        "autoAdvanceChapter",
        "forceScreenMode",
        "screenMode",
        "ghostCleanInterval",
        "preferredLanguages",
        "offlineMode",
        "enabledSources",
        "keyboardLayout"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'blackAndWhiteChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'autoAdvanceChapterChanged'
        QtMocHelpers::SignalData<void()>(3, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'forceScreenModeChanged'
        QtMocHelpers::SignalData<void()>(4, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'screenModeChanged'
        QtMocHelpers::SignalData<void()>(5, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'ghostCleanIntervalChanged'
        QtMocHelpers::SignalData<void()>(6, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'preferredLanguagesChanged'
        QtMocHelpers::SignalData<void()>(7, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'offlineModeChanged'
        QtMocHelpers::SignalData<void()>(8, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'enabledSourcesChanged'
        QtMocHelpers::SignalData<void()>(9, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'keyboardLayoutChanged'
        QtMocHelpers::SignalData<void()>(10, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'isSourceEnabled'
        QtMocHelpers::MethodData<bool(const QString &) const>(11, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 12 },
        }}),
        // Method 'toggleSource'
        QtMocHelpers::MethodData<void(const QString &)>(13, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 12 },
        }}),
        // Method 'toggleKeyboardLayout'
        QtMocHelpers::MethodData<void()>(14, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'toggleLanguage'
        QtMocHelpers::MethodData<void(const QString &)>(15, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 16 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'blackAndWhite'
        QtMocHelpers::PropertyData<bool>(17, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 0),
        // property 'autoAdvanceChapter'
        QtMocHelpers::PropertyData<bool>(18, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 1),
        // property 'forceScreenMode'
        QtMocHelpers::PropertyData<bool>(19, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 2),
        // property 'screenMode'
        QtMocHelpers::PropertyData<QString>(20, QMetaType::QString, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 3),
        // property 'ghostCleanInterval'
        QtMocHelpers::PropertyData<int>(21, QMetaType::Int, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 4),
        // property 'preferredLanguages'
        QtMocHelpers::PropertyData<QStringList>(22, QMetaType::QStringList, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 5),
        // property 'offlineMode'
        QtMocHelpers::PropertyData<bool>(23, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 6),
        // property 'enabledSources'
        QtMocHelpers::PropertyData<QStringList>(24, QMetaType::QStringList, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 7),
        // property 'keyboardLayout'
        QtMocHelpers::PropertyData<QString>(25, QMetaType::QString, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 8),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<SettingsStore, qt_meta_tag_ZN13SettingsStoreE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject SettingsStore::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN13SettingsStoreE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN13SettingsStoreE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN13SettingsStoreE_t>.metaTypes,
    nullptr
} };

void SettingsStore::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<SettingsStore *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->blackAndWhiteChanged(); break;
        case 1: _t->autoAdvanceChapterChanged(); break;
        case 2: _t->forceScreenModeChanged(); break;
        case 3: _t->screenModeChanged(); break;
        case 4: _t->ghostCleanIntervalChanged(); break;
        case 5: _t->preferredLanguagesChanged(); break;
        case 6: _t->offlineModeChanged(); break;
        case 7: _t->enabledSourcesChanged(); break;
        case 8: _t->keyboardLayoutChanged(); break;
        case 9: { bool _r = _t->isSourceEnabled((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 10: _t->toggleSource((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 11: _t->toggleKeyboardLayout(); break;
        case 12: _t->toggleLanguage((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (SettingsStore::*)()>(_a, &SettingsStore::blackAndWhiteChanged, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (SettingsStore::*)()>(_a, &SettingsStore::autoAdvanceChapterChanged, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (SettingsStore::*)()>(_a, &SettingsStore::forceScreenModeChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (SettingsStore::*)()>(_a, &SettingsStore::screenModeChanged, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (SettingsStore::*)()>(_a, &SettingsStore::ghostCleanIntervalChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (SettingsStore::*)()>(_a, &SettingsStore::preferredLanguagesChanged, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (SettingsStore::*)()>(_a, &SettingsStore::offlineModeChanged, 6))
            return;
        if (QtMocHelpers::indexOfMethod<void (SettingsStore::*)()>(_a, &SettingsStore::enabledSourcesChanged, 7))
            return;
        if (QtMocHelpers::indexOfMethod<void (SettingsStore::*)()>(_a, &SettingsStore::keyboardLayoutChanged, 8))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<bool*>(_v) = _t->blackAndWhite(); break;
        case 1: *reinterpret_cast<bool*>(_v) = _t->autoAdvanceChapter(); break;
        case 2: *reinterpret_cast<bool*>(_v) = _t->forceScreenMode(); break;
        case 3: *reinterpret_cast<QString*>(_v) = _t->screenMode(); break;
        case 4: *reinterpret_cast<int*>(_v) = _t->ghostCleanInterval(); break;
        case 5: *reinterpret_cast<QStringList*>(_v) = _t->preferredLanguages(); break;
        case 6: *reinterpret_cast<bool*>(_v) = _t->offlineMode(); break;
        case 7: *reinterpret_cast<QStringList*>(_v) = _t->enabledSources(); break;
        case 8: *reinterpret_cast<QString*>(_v) = _t->keyboardLayout(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setBlackAndWhite(*reinterpret_cast<bool*>(_v)); break;
        case 1: _t->setAutoAdvanceChapter(*reinterpret_cast<bool*>(_v)); break;
        case 2: _t->setForceScreenMode(*reinterpret_cast<bool*>(_v)); break;
        case 3: _t->setScreenMode(*reinterpret_cast<QString*>(_v)); break;
        case 4: _t->setGhostCleanInterval(*reinterpret_cast<int*>(_v)); break;
        case 5: _t->setPreferredLanguages(*reinterpret_cast<QStringList*>(_v)); break;
        case 6: _t->setOfflineMode(*reinterpret_cast<bool*>(_v)); break;
        case 7: _t->setEnabledSources(*reinterpret_cast<QStringList*>(_v)); break;
        case 8: _t->setKeyboardLayout(*reinterpret_cast<QString*>(_v)); break;
        default: break;
        }
    }
}

const QMetaObject *SettingsStore::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *SettingsStore::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN13SettingsStoreE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int SettingsStore::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 13)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 13;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 13)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 13;
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
void SettingsStore::blackAndWhiteChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void SettingsStore::autoAdvanceChapterChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void SettingsStore::forceScreenModeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void SettingsStore::screenModeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void SettingsStore::ghostCleanIntervalChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void SettingsStore::preferredLanguagesChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void SettingsStore::offlineModeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}

// SIGNAL 7
void SettingsStore::enabledSourcesChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 7, nullptr);
}

// SIGNAL 8
void SettingsStore::keyboardLayoutChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 8, nullptr);
}
QT_WARNING_POP
