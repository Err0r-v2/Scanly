#pragma once

#include <QObject>
#include <QSettings>
#include <QStringList>

class SettingsStore : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool blackAndWhite READ blackAndWhite WRITE setBlackAndWhite NOTIFY blackAndWhiteChanged)
    Q_PROPERTY(bool autoAdvanceChapter READ autoAdvanceChapter WRITE setAutoAdvanceChapter NOTIFY autoAdvanceChapterChanged)
    Q_PROPERTY(bool forceScreenMode READ forceScreenMode WRITE setForceScreenMode NOTIFY forceScreenModeChanged)
    Q_PROPERTY(QString screenMode READ screenMode WRITE setScreenMode NOTIFY screenModeChanged)
    Q_PROPERTY(int ghostCleanInterval READ ghostCleanInterval WRITE setGhostCleanInterval NOTIFY ghostCleanIntervalChanged)
    Q_PROPERTY(QStringList preferredLanguages READ preferredLanguages WRITE setPreferredLanguages NOTIFY preferredLanguagesChanged)
    Q_PROPERTY(bool offlineMode READ offlineMode WRITE setOfflineMode NOTIFY offlineModeChanged)
    Q_PROPERTY(QStringList enabledSources READ enabledSources WRITE setEnabledSources NOTIFY enabledSourcesChanged)
    Q_PROPERTY(QString keyboardLayout READ keyboardLayout WRITE setKeyboardLayout NOTIFY keyboardLayoutChanged)

public:
    explicit SettingsStore(QObject *parent = nullptr);

    bool blackAndWhite() const { return m_bw; }
    void setBlackAndWhite(bool v);

    bool autoAdvanceChapter() const { return m_autoAdvance; }
    void setAutoAdvanceChapter(bool v);

    bool forceScreenMode() const { return m_forceScreenMode; }
    void setForceScreenMode(bool v);

    QString screenMode() const { return m_screenMode; }
    void setScreenMode(const QString &v);

    int ghostCleanInterval() const { return m_ghostCleanInterval; }
    void setGhostCleanInterval(int v);

    QStringList preferredLanguages() const { return m_languages; }
    void setPreferredLanguages(const QStringList &v);

    bool offlineMode() const { return m_offline; }
    void setOfflineMode(bool v);

    QStringList enabledSources() const { return m_enabledSources; }
    void setEnabledSources(const QStringList &v);

    Q_INVOKABLE bool isSourceEnabled(const QString &key) const;
    Q_INVOKABLE void toggleSource(const QString &key);

    QString keyboardLayout() const { return m_keyboardLayout; }
    void setKeyboardLayout(const QString &v);
    Q_INVOKABLE void toggleKeyboardLayout();

private:
    void applyWifiRadio(bool on);

public:

    Q_INVOKABLE void toggleLanguage(const QString &code);

signals:
    void blackAndWhiteChanged();
    void autoAdvanceChapterChanged();
    void forceScreenModeChanged();
    void screenModeChanged();
    void ghostCleanIntervalChanged();
    void preferredLanguagesChanged();
    void offlineModeChanged();
    void enabledSourcesChanged();
    void keyboardLayoutChanged();

private:
    QSettings m_settings;
    bool m_bw;
    bool m_autoAdvance;
    bool m_forceScreenMode;
    QString m_screenMode;
    int m_ghostCleanInterval;
    QStringList m_languages;
    bool m_offline;
    QStringList m_enabledSources;
    QString m_keyboardLayout;
};
