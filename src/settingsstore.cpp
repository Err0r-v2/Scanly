#include "settingsstore.h"

#include <QDebug>
#include <QProcess>
#include <QtGlobal>

namespace {
int normalizedGhostCleanInterval(int pages)
{
    return qBound(1, pages, 60);
}

QString normalizedScreenMode(const QString &mode)
{
    if (mode.compare("Animation", Qt::CaseInsensitive) == 0)
        return QStringLiteral("Animation");
    if (mode.compare("Mono", Qt::CaseInsensitive) == 0)
        return QStringLiteral("Mono");
    if (mode.compare("Content", Qt::CaseInsensitive) == 0)
        return QStringLiteral("Content");
    return QStringLiteral("Content");
}
}

SettingsStore::SettingsStore(QObject *parent)
    : QObject(parent)
    , m_bw(m_settings.value("display/blackAndWhite", false).toBool())
    , m_autoAdvance(m_settings.value("reading/autoAdvanceChapter", false).toBool())
    , m_forceScreenMode(m_settings.value("display/forceScreenMode", true).toBool())
    , m_screenMode(normalizedScreenMode(m_settings.value("display/screenMode",
                                                         QStringLiteral("Content")).toString()))
    , m_ghostCleanInterval(normalizedGhostCleanInterval(m_settings.value("display/ghostCleanInterval", 12).toInt()))
    , m_languages(m_settings.value("reading/preferredLanguages",
                                    QStringList{"en"}).toStringList())
    , m_offline(m_settings.value("network/offlineMode", false).toBool())
    , m_enabledSources(m_settings.value("sources/enabled",
                                        QStringList{"scanmirror", "weebcentral"}).toStringList())
    , m_keyboardLayout(m_settings.value("input/keyboardLayout",
                                        QStringLiteral("qwerty")).toString())
{
    if (m_languages.isEmpty()) m_languages = QStringList{"en"};
    if (m_enabledSources.isEmpty()) m_enabledSources = QStringList{"scanmirror", "weebcentral"};
    if (m_offline) applyWifiRadio(false);
}

void SettingsStore::setBlackAndWhite(bool v)
{
    if (m_bw == v) return;
    m_bw = v;
    m_settings.setValue("display/blackAndWhite", v);
    emit blackAndWhiteChanged();
}

void SettingsStore::setAutoAdvanceChapter(bool v)
{
    if (m_autoAdvance == v) return;
    m_autoAdvance = v;
    m_settings.setValue("reading/autoAdvanceChapter", v);
    emit autoAdvanceChapterChanged();
}

void SettingsStore::setForceScreenMode(bool v)
{
    if (m_forceScreenMode == v) return;
    m_forceScreenMode = v;
    m_settings.setValue("display/forceScreenMode", v);
    emit forceScreenModeChanged();
}

void SettingsStore::setScreenMode(const QString &v)
{
    const QString clean = normalizedScreenMode(v);
    if (m_screenMode == clean) return;
    m_screenMode = clean;
    m_settings.setValue("display/screenMode", m_screenMode);
    emit screenModeChanged();
}

void SettingsStore::setGhostCleanInterval(int v)
{
    const int clean = normalizedGhostCleanInterval(v);
    if (m_ghostCleanInterval == clean) return;
    m_ghostCleanInterval = clean;
    m_settings.setValue("display/ghostCleanInterval", m_ghostCleanInterval);
    emit ghostCleanIntervalChanged();
}

void SettingsStore::setPreferredLanguages(const QStringList &v)
{
    auto clean = v;
    clean.removeAll(QString());
    if (clean.isEmpty()) clean = QStringList{"en"};
    if (m_languages == clean) return;
    m_languages = clean;
    m_settings.setValue("reading/preferredLanguages", m_languages);
    emit preferredLanguagesChanged();
}

void SettingsStore::setOfflineMode(bool v)
{
    if (m_offline == v) return;
    m_offline = v;
    m_settings.setValue("network/offlineMode", v);
    applyWifiRadio(!v);
    emit offlineModeChanged();
}

void SettingsStore::setEnabledSources(const QStringList &v)
{
    QStringList clean = v;
    clean.removeAll(QString());
    clean.removeDuplicates();
    if (clean.isEmpty()) clean = QStringList{"scanmirror", "weebcentral"};
    if (m_enabledSources == clean) return;
    m_enabledSources = clean;
    m_settings.setValue("sources/enabled", m_enabledSources);
    emit enabledSourcesChanged();
}

bool SettingsStore::isSourceEnabled(const QString &key) const
{
    return m_enabledSources.contains(key);
}

void SettingsStore::setKeyboardLayout(const QString &v)
{
    QString clean = v.compare("azerty", Qt::CaseInsensitive) == 0
        ? QStringLiteral("azerty")
        : QStringLiteral("qwerty");
    if (m_keyboardLayout == clean) return;
    m_keyboardLayout = clean;
    m_settings.setValue("input/keyboardLayout", m_keyboardLayout);
    emit keyboardLayoutChanged();
}

void SettingsStore::toggleKeyboardLayout()
{
    setKeyboardLayout(m_keyboardLayout == QLatin1String("azerty")
                      ? QStringLiteral("qwerty")
                      : QStringLiteral("azerty"));
}

void SettingsStore::toggleSource(const QString &key)
{
    QStringList next = m_enabledSources;
    if (next.contains(key)) {
        if (next.size() <= 1) return; // au moins une source toujours active
        next.removeAll(key);
    } else {
        next.append(key);
    }
    setEnabledSources(next);
}

void SettingsStore::applyWifiRadio(bool on)
{
#if defined(Q_OS_LINUX)
    // reMarkable runs as root, so rfkill works without sudo.
    const QStringList args = on ? QStringList{"unblock", "wifi"}
                                : QStringList{"block", "wifi"};
    const int rc = QProcess::execute("rfkill", args);
    if (rc != 0)
        qWarning() << "[Settings] rfkill" << args << "exit=" << rc;
#elif defined(Q_OS_MACOS)
    // Common Wi-Fi interface is en0; networksetup may prompt for admin.
    const QString iface = "en0";
    const QStringList args{"-setairportpower", iface, on ? "on" : "off"};
    const int rc = QProcess::execute("/usr/sbin/networksetup", args);
    if (rc != 0)
        qWarning() << "[Settings] networksetup" << args << "exit=" << rc;
#else
    Q_UNUSED(on);
#endif
}

void SettingsStore::toggleLanguage(const QString &code)
{
    auto next = m_languages;
    if (next.contains(code)) next.removeAll(code);
    else                     next.append(code);
    setPreferredLanguages(next);
}
