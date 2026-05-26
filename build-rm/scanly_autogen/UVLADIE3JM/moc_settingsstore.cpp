/****************************************************************************
** Meta object code from reading C++ file 'settingsstore.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.8.2)
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
struct qt_meta_tag_ZN13SettingsStoreE_t {};
} // unnamed namespace


#ifdef QT_MOC_HAS_STRINGDATA
static constexpr auto qt_meta_stringdata_ZN13SettingsStoreE = QtMocHelpers::stringData(
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
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA

Q_CONSTINIT static const uint qt_meta_data_ZN13SettingsStoreE[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
      13,   14, // methods
       9,  111, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       9,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,   92,    2, 0x06,   10 /* Public */,
       3,    0,   93,    2, 0x06,   11 /* Public */,
       4,    0,   94,    2, 0x06,   12 /* Public */,
       5,    0,   95,    2, 0x06,   13 /* Public */,
       6,    0,   96,    2, 0x06,   14 /* Public */,
       7,    0,   97,    2, 0x06,   15 /* Public */,
       8,    0,   98,    2, 0x06,   16 /* Public */,
       9,    0,   99,    2, 0x06,   17 /* Public */,
      10,    0,  100,    2, 0x06,   18 /* Public */,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
      11,    1,  101,    2, 0x102,   19 /* Public | MethodIsConst  */,
      13,    1,  104,    2, 0x02,   21 /* Public */,
      14,    0,  107,    2, 0x02,   23 /* Public */,
      15,    1,  108,    2, 0x02,   24 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // methods: parameters
    QMetaType::Bool, QMetaType::QString,   12,
    QMetaType::Void, QMetaType::QString,   12,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,   16,

 // properties: name, type, flags, notifyId, revision
      17, QMetaType::Bool, 0x00015103, uint(0), 0,
      18, QMetaType::Bool, 0x00015103, uint(1), 0,
      19, QMetaType::Bool, 0x00015103, uint(2), 0,
      20, QMetaType::QString, 0x00015103, uint(3), 0,
      21, QMetaType::Int, 0x00015103, uint(4), 0,
      22, QMetaType::QStringList, 0x00015103, uint(5), 0,
      23, QMetaType::Bool, 0x00015103, uint(6), 0,
      24, QMetaType::QStringList, 0x00015103, uint(7), 0,
      25, QMetaType::QString, 0x00015103, uint(8), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject SettingsStore::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_ZN13SettingsStoreE.offsetsAndSizes,
    qt_meta_data_ZN13SettingsStoreE,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_tag_ZN13SettingsStoreE_t,
        // property 'blackAndWhite'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'autoAdvanceChapter'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'forceScreenMode'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'screenMode'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'ghostCleanInterval'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'preferredLanguages'
        QtPrivate::TypeAndForceComplete<QStringList, std::true_type>,
        // property 'offlineMode'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'enabledSources'
        QtPrivate::TypeAndForceComplete<QStringList, std::true_type>,
        // property 'keyboardLayout'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<SettingsStore, std::true_type>,
        // method 'blackAndWhiteChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'autoAdvanceChapterChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'forceScreenModeChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'screenModeChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'ghostCleanIntervalChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'preferredLanguagesChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'offlineModeChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'enabledSourcesChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'keyboardLayoutChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'isSourceEnabled'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'toggleSource'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'toggleKeyboardLayout'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'toggleLanguage'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>
    >,
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
        case 9: { bool _r = _t->isSourceEnabled((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 10: _t->toggleSource((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 11: _t->toggleKeyboardLayout(); break;
        case 12: _t->toggleLanguage((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _q_method_type = void (SettingsStore::*)();
            if (_q_method_type _q_method = &SettingsStore::blackAndWhiteChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _q_method_type = void (SettingsStore::*)();
            if (_q_method_type _q_method = &SettingsStore::autoAdvanceChapterChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
        {
            using _q_method_type = void (SettingsStore::*)();
            if (_q_method_type _q_method = &SettingsStore::forceScreenModeChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 2;
                return;
            }
        }
        {
            using _q_method_type = void (SettingsStore::*)();
            if (_q_method_type _q_method = &SettingsStore::screenModeChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 3;
                return;
            }
        }
        {
            using _q_method_type = void (SettingsStore::*)();
            if (_q_method_type _q_method = &SettingsStore::ghostCleanIntervalChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 4;
                return;
            }
        }
        {
            using _q_method_type = void (SettingsStore::*)();
            if (_q_method_type _q_method = &SettingsStore::preferredLanguagesChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 5;
                return;
            }
        }
        {
            using _q_method_type = void (SettingsStore::*)();
            if (_q_method_type _q_method = &SettingsStore::offlineModeChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 6;
                return;
            }
        }
        {
            using _q_method_type = void (SettingsStore::*)();
            if (_q_method_type _q_method = &SettingsStore::enabledSourcesChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 7;
                return;
            }
        }
        {
            using _q_method_type = void (SettingsStore::*)();
            if (_q_method_type _q_method = &SettingsStore::keyboardLayoutChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 8;
                return;
            }
        }
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< bool*>(_v) = _t->blackAndWhite(); break;
        case 1: *reinterpret_cast< bool*>(_v) = _t->autoAdvanceChapter(); break;
        case 2: *reinterpret_cast< bool*>(_v) = _t->forceScreenMode(); break;
        case 3: *reinterpret_cast< QString*>(_v) = _t->screenMode(); break;
        case 4: *reinterpret_cast< int*>(_v) = _t->ghostCleanInterval(); break;
        case 5: *reinterpret_cast< QStringList*>(_v) = _t->preferredLanguages(); break;
        case 6: *reinterpret_cast< bool*>(_v) = _t->offlineMode(); break;
        case 7: *reinterpret_cast< QStringList*>(_v) = _t->enabledSources(); break;
        case 8: *reinterpret_cast< QString*>(_v) = _t->keyboardLayout(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setBlackAndWhite(*reinterpret_cast< bool*>(_v)); break;
        case 1: _t->setAutoAdvanceChapter(*reinterpret_cast< bool*>(_v)); break;
        case 2: _t->setForceScreenMode(*reinterpret_cast< bool*>(_v)); break;
        case 3: _t->setScreenMode(*reinterpret_cast< QString*>(_v)); break;
        case 4: _t->setGhostCleanInterval(*reinterpret_cast< int*>(_v)); break;
        case 5: _t->setPreferredLanguages(*reinterpret_cast< QStringList*>(_v)); break;
        case 6: _t->setOfflineMode(*reinterpret_cast< bool*>(_v)); break;
        case 7: _t->setEnabledSources(*reinterpret_cast< QStringList*>(_v)); break;
        case 8: _t->setKeyboardLayout(*reinterpret_cast< QString*>(_v)); break;
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
    if (!strcmp(_clname, qt_meta_stringdata_ZN13SettingsStoreE.stringdata0))
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
