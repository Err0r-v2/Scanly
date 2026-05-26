#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QFile>
#include <QFileInfo>
#include <QString>
#include <QStringList>
#include "sushiscansource.h"
#include "weebcentralsource.h"
#include "mangasourcerouter.h"
#include "searchmodel.h"
#include "imagecache.h"
#include "librarystore.h"
#include "downloadmanager.h"
#include "settingsstore.h"
#include "epaperhints.h"
#include "devicestatus.h"
#include "pageimagecache.h"
#include "mangametasource.h"

namespace {

constexpr auto kXochitlConfPath = "/home/root/.config/remarkable/xochitl.conf";
constexpr auto kLockedKeyPrefix = "OrientationLocked=";
constexpr auto kPreviousKeyPrefix = "PreviousLockedOrientation=";
constexpr auto kGeneralSection = "[General]";

struct XochitlOrientationSnapshot {
    bool valid = false;
    bool hadLockedKey = false;
    QString lockedValue;
    bool hadPreviousKey = false;
    QString previousValue;
};

XochitlOrientationSnapshot readXochitlOrientation()
{
    XochitlOrientationSnapshot snap;
    QFile file(QString::fromLatin1(kXochitlConfPath));
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return snap;
    snap.valid = true;
    while (!file.atEnd()) {
        const QString line = QString::fromUtf8(file.readLine()).trimmed();
        if (line.startsWith(QLatin1String(kLockedKeyPrefix))) {
            snap.hadLockedKey = true;
            snap.lockedValue = line.section('=', 1);
        } else if (line.startsWith(QLatin1String(kPreviousKeyPrefix))) {
            snap.hadPreviousKey = true;
            snap.previousValue = line.section('=', 1);
        }
    }
    return snap;
}

// xochitl re-reads xochitl.conf live via QFileSystemWatcher, so writing here
// takes effect immediately while scanly is in the foreground.
bool writeXochitlOrientation(bool locked, const QString &previous)
{
    QFile file(QString::fromLatin1(kXochitlConfPath));
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return false;
    QStringList lines;
    while (!file.atEnd())
        lines << QString::fromUtf8(file.readLine()).trimmed();
    file.close();

    const QString lockedLine = QLatin1String(kLockedKeyPrefix) + QLatin1String(locked ? "true" : "false");
    const QString prevLine = QLatin1String(kPreviousKeyPrefix) + previous;

    bool sawLocked = false, sawPrev = false;
    int generalIdx = -1;
    for (int i = 0; i < lines.size(); ++i) {
        const QString &l = lines[i];
        if (l == QLatin1String(kGeneralSection))
            generalIdx = i;
        if (l.startsWith(QLatin1String(kLockedKeyPrefix))) {
            lines[i] = lockedLine;
            sawLocked = true;
        } else if (l.startsWith(QLatin1String(kPreviousKeyPrefix))) {
            lines[i] = prevLine;
            sawPrev = true;
        }
    }

    const int insertAt = (generalIdx >= 0 ? generalIdx + 1 : 0);
    if (!sawPrev)
        lines.insert(insertAt, prevLine);
    if (!sawLocked)
        lines.insert(insertAt, lockedLine);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text))
        return false;
    file.write(lines.join('\n').toUtf8());
    file.write("\n");
    file.close();
    return true;
}

} // namespace

int main(int argc, char *argv[])
{
    // QTFB_KEY is set by rm-appload, which preloads qtfb-shim.so to route the
    // linuxfb framebuffer to AppLoad's shared memory. Without it we are in
    // desktop preview mode (Cocoa/XCB), so scale down to fit a laptop screen.
    const bool underAppLoad = qEnvironmentVariableIsSet("QTFB_KEY");

    if (!underAppLoad && !qEnvironmentVariableIsSet("QT_SCALE_FACTOR")) {
        const QByteArray override = qgetenv("SCANLY_PREVIEW_SCALE");
        qputenv("QT_SCALE_FACTOR", override.isEmpty() ? "0.5" : override);
    }

    QGuiApplication app(argc, argv);
    app.setOrganizationName("Scanly");
    app.setApplicationName("Scanly");
    QQuickStyle::setStyle("Basic");

    // Lock xochitl orientation to Portrait while scanly runs under AppLoad,
    // otherwise xochitl auto-rotates the framebuffer and undoes our in-app
    // landscape layout. Snapshot the previous config so we can restore it
    // on exit.
    XochitlOrientationSnapshot xochitlSnapshot;
    if (underAppLoad) {
        xochitlSnapshot = readXochitlOrientation();
        const bool alreadyLocked = xochitlSnapshot.hadLockedKey
            && xochitlSnapshot.lockedValue.compare("true", Qt::CaseInsensitive) == 0
            && xochitlSnapshot.hadPreviousKey
            && xochitlSnapshot.previousValue == QStringLiteral("0");
        if (xochitlSnapshot.valid && !alreadyLocked)
            writeXochitlOrientation(true, QStringLiteral("0"));
    }
    QObject::connect(&app, &QGuiApplication::aboutToQuit, [xochitlSnapshot]() {
        if (!xochitlSnapshot.valid)
            return;
        const bool prevLocked = (xochitlSnapshot.lockedValue.compare("true", Qt::CaseInsensitive) == 0);
        const QString prevEnum = xochitlSnapshot.hadPreviousKey ? xochitlSnapshot.previousValue
                                                                : QStringLiteral("0");
        writeXochitlOrientation(prevLocked, prevEnum);
    });

    ImageCache imageCache;
    SettingsStore settings;
    SushiScanSource frSource;
    WeebCentralSource enSource;
    MangaSourceRouter router(&frSource, &enSource, &settings);
    SearchModel searchModel;
    LibraryStore library;
    DownloadManager downloads(&router);
    EpaperHints epaper;
    DeviceStatus device;
    PageImageCache pageImages;
    MangaMetaSource meta;

    QObject::connect(&router, &MangaSourceRouter::searchResults,
                     &searchModel, &SearchModel::updateFrom);

    QQmlApplicationEngine engine;
    static ScanlyNamFactory namFactory(&imageCache);
    engine.setNetworkAccessManagerFactory(&namFactory);

    auto *ctx = engine.rootContext();
    ctx->setContextProperty("source", &router);
    ctx->setContextProperty("searchModel", &searchModel);
    ctx->setContextProperty("imageCache", &imageCache);
    ctx->setContextProperty("libraryStore", &library);
    ctx->setContextProperty("downloads", &downloads);
    ctx->setContextProperty("settings", &settings);
    ctx->setContextProperty("epaper", &epaper);
    ctx->setContextProperty("device", &device);
    ctx->setContextProperty("pageImages", &pageImages);
    ctx->setContextProperty("meta", &meta);
    engine.loadFromModule("app.scanly", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
