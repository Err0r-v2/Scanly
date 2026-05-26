#include "epaperhints.h"

#include <QFile>
#include <QString>
#include <QtGlobal>

namespace {
constexpr auto kAppLoadDefaultModePath = "/tmp/scanly-qtfb-default-mode";
constexpr auto kAppLoadForceFullPath = "/tmp/scanly-qtfb-force-full";

void writeAppLoadMode(const QString &mode)
{
    QFile file(kAppLoadDefaultModePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return;
    file.write(mode.toUtf8());
    file.write("\n");
}
}

EpaperHints::EpaperHints(QObject *parent) : QObject(parent) {}

void EpaperHints::setAppLoadRefreshMode(const QString &mode)
{
    writeAppLoadMode(mode);
}

void EpaperHints::resetAppLoadRefreshMode()
{
    writeAppLoadMode(QStringLiteral("Content"));
}

bool EpaperHints::clearGhosting()
{
    QFile flag(kAppLoadForceFullPath);
    if (!flag.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return false;
    flag.write("1");
    return true;
}
