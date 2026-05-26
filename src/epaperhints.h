#pragma once

#include <QObject>

// Refresh-mode facade for the linuxfb plugin patch used under rm-appload.
// Writes the requested mode to /tmp/scanly-qtfb-default-mode and a one-shot
// "force full refresh" flag to /tmp/scanly-qtfb-force-full; the patched
// linuxfb plugin consumes both on the next ioctl. See packaging/appload/.
class EpaperHints : public QObject
{
    Q_OBJECT
public:
    explicit EpaperHints(QObject *parent = nullptr);

    Q_INVOKABLE void setAppLoadRefreshMode(const QString &mode);
    Q_INVOKABLE void resetAppLoadRefreshMode();
    Q_INVOKABLE bool clearGhosting();

    // Kept as no-ops so existing QML call sites don't need to be edited.
    Q_INVOKABLE void partialRefresh() {}
    Q_INVOKABLE void fullRefresh() {}
};
