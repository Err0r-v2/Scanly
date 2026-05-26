#include "devicestatus.h"

#include <QProcess>
#include <QFile>
#include <QDir>
#include <QRegularExpression>
#include <QDateTime>
#include <QNetworkInformation>
#include <QStorageInfo>
#include <QtGlobal>

DeviceStatus::DeviceStatus(QObject *parent) : QObject(parent)
{
    if (QNetworkInformation::loadDefaultBackend()) {
        if (auto *info = QNetworkInformation::instance()) {
            m_online = info->reachability() == QNetworkInformation::Reachability::Online;
            connect(info, &QNetworkInformation::reachabilityChanged, this,
                [this](QNetworkInformation::Reachability r) {
                    const bool next = r == QNetworkInformation::Reachability::Online;
                    if (next != m_online) { m_online = next; emit changed(); }
                });
        }
    }

    refresh();
    m_statusTimer.setInterval(30 * 1000);
    connect(&m_statusTimer, &QTimer::timeout, this, &DeviceStatus::refresh);
    m_statusTimer.start();

    // Always poll the accelerometer, including under AppLoad. AppLoad/xochitl
    // does its own surface rotation but never tells the guest app, we still
    // need the angle ourselves to decide layout (2-page spread, etc.).
    m_orientationTimer.setInterval(1000);
    connect(&m_orientationTimer, &QTimer::timeout, this, &DeviceStatus::refreshOrientation);
    m_orientationTimer.start();
    refreshOrientation();

    m_clockTimer.setInterval(15 * 1000);
    connect(&m_clockTimer, &QTimer::timeout, this, &DeviceStatus::tick);
    m_clockTimer.start();
}

QString DeviceStatus::currentTime() const
{
    return QDateTime::currentDateTime().toString("HH:mm");
}

void DeviceStatus::refresh()
{
    const int oldB = m_battery;
    const bool oldC = m_charging;
    const bool oldOnline = m_online;
    const qint64 oldStorageTotal = m_storageTotal;
    const qint64 oldStorageFree = m_storageFree;
    readBattery();
    readStorage();
    m_online = readOnline();
    if (m_battery != oldB || m_charging != oldC || m_online != oldOnline
        || m_storageTotal != oldStorageTotal || m_storageFree != oldStorageFree)
        emit changed();
}

void DeviceStatus::refreshOrientation()
{
    const int nextRotation = readRotationAngle(m_rotationAngle);
    const bool nextLandscape = qAbs(nextRotation) == 90;
    if (nextRotation != m_rotationAngle || nextLandscape != m_landscape) {
        m_rotationAngle = nextRotation;
        m_landscape = nextLandscape;
        emit changed();
    }
}

void DeviceStatus::readBattery()
{
#if defined(Q_OS_LINUX)
    readBatteryLinux();
#elif defined(Q_OS_MACOS)
    readBatteryMac();
#endif
}

void DeviceStatus::readBatteryMac()
{
    QProcess p;
    p.start("/usr/bin/pmset", {"-g", "batt"});
    if (!p.waitForFinished(2000)) return;
    const auto out = QString::fromUtf8(p.readAllStandardOutput());

    QRegularExpression rePct(R"((\d+)%)");
    const auto m = rePct.match(out);
    if (m.hasMatch()) m_battery = m.captured(1).toInt();

    m_charging = out.contains("AC Power")
              || out.contains("charging", Qt::CaseInsensitive);
}

void DeviceStatus::readBatteryLinux()
{
    // Try common power supply paths on reMarkable Paper Pro.
    static const QStringList candidates{
        "/sys/class/power_supply/max1726x_battery",
        "/sys/class/power_supply/max77818_battery",
        "/sys/class/power_supply/bd71827_bat",
        "/sys/class/power_supply/bq27441-0",
    };

    auto readTrimmed = [](const QString &path) {
        QFile file(path);
        if (!file.open(QIODevice::ReadOnly))
            return QString();
        return QString::fromUtf8(file.readAll()).trimmed();
    };

    auto isTabletBattery = [&readTrimmed](const QString &path) {
        if (!QDir(path).exists())
            return false;

        const QString name = QFileInfo(path).fileName();
        if (name.contains("marker", Qt::CaseInsensitive))
            return false;

        if (readTrimmed(path + "/type") != "Battery")
            return false;

        bool ok = false;
        readTrimmed(path + "/capacity").toInt(&ok);
        return ok;
    };

    QString picked;
    for (const auto &c : candidates) {
        if (isTabletBattery(c)) { picked = c; break; }
    }
    if (picked.isEmpty()) {
        QDir d("/sys/class/power_supply");
        const auto entries = d.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
        for (const auto &e : entries) {
            const QString path = "/sys/class/power_supply/" + e;
            if (isTabletBattery(path)) {
                picked = path; break;
            }
        }
    }
    if (picked.isEmpty()) return;

    bool ok = false;
    const int capacity = readTrimmed(picked + "/capacity").toInt(&ok);
    if (ok)
        m_battery = qBound(0, capacity, 100);

    const QString status = readTrimmed(picked + "/status");
    m_charging = status == "Charging" || status == "Full";
}

void DeviceStatus::readStorage()
{
#if defined(Q_OS_LINUX)
    QStorageInfo storage("/home");
    if (!storage.isValid() || !storage.isReady())
        storage.setPath("/");
#elif defined(Q_OS_MACOS)
    QStorageInfo storage(QDir::homePath());
#else
    QStorageInfo storage = QStorageInfo::root();
#endif

    if (!storage.isValid() || !storage.isReady())
        return;

    m_storageTotal = storage.bytesTotal();
    m_storageFree = storage.bytesAvailable();
}

bool DeviceStatus::readOnline() const
{
#if defined(Q_OS_LINUX)
    return readOnlineLinux();
#else
    if (auto *info = QNetworkInformation::instance())
        return info->reachability() == QNetworkInformation::Reachability::Online;
    return m_online;
#endif
}

bool DeviceStatus::readOnlineLinux() const
{
    QFile routes("/proc/net/route");
    if (!routes.open(QIODevice::ReadOnly))
        return m_online;

    const QList<QByteArray> lines = routes.readAll().split('\n');
    for (int i = 1; i < lines.size(); ++i) {
        const QList<QByteArray> fields = lines.at(i).simplified().split(' ');
        if (fields.size() < 4 || fields.at(1) != "00000000")
            continue;

        bool ok = false;
        const int flags = fields.at(3).toInt(&ok, 16);
        if (!ok || (flags & 0x1) == 0)
            continue;

        const QString iface = QString::fromUtf8(fields.at(0));
        QFile operstate("/sys/class/net/" + iface + "/operstate");
        if (operstate.open(QIODevice::ReadOnly)) {
            const QString state = QString::fromUtf8(operstate.readAll()).trimmed();
            if (state == "down" || state == "dormant")
                continue;
        }

        QFile carrier("/sys/class/net/" + iface + "/carrier");
        if (carrier.open(QIODevice::ReadOnly)
            && QString::fromUtf8(carrier.readAll()).trimmed() == "0") {
            continue;
        }

        return true;
    }

    return false;
}

int DeviceStatus::readRotationAngle(int fallback) const
{
#if defined(Q_OS_LINUX)
    return readRotationAngleLinux(fallback);
#else
    return fallback;
#endif
}

int DeviceStatus::readRotationAngleLinux(int fallback) const
{
    // The iio device path doesn't change at runtime, so resolve it once.
    static const QString accelPath = [] {
        QDir iio("/sys/bus/iio/devices");
        const QStringList devices = iio.entryList(QStringList{"iio:device*"},
                                                  QDir::Dirs | QDir::NoDotAndDotDot);
        for (const QString &device : devices) {
            QFile name(iio.filePath(device + "/name"));
            if (!name.open(QIODevice::ReadOnly))
                continue;
            if (QString::fromUtf8(name.readAll()).trimmed() == "lis2dw12_accel")
                return iio.filePath(device);
        }
        return QString();
    }();
    if (accelPath.isEmpty())
        return fallback;

    auto readRaw = [](const QString &path, bool *ok) {
        QFile file(path);
        if (!file.open(QIODevice::ReadOnly)) {
            *ok = false;
            return 0;
        }
        return QString::fromUtf8(file.readAll()).trimmed().toInt(ok);
    };

    bool okX = false;
    bool okY = false;
    const int x = readRaw(accelPath + "/in_accel_x_raw", &okX);
    const int y = readRaw(accelPath + "/in_accel_y_raw", &okY);
    if (!okX || !okY)
        return fallback;

    const int ax = qAbs(x);
    const int ay = qAbs(y);
    const int dominant = qMax(ax, ay);
    const int quiet = qMin(ax, ay);

    // Keep the previous value when the tablet is close to a diagonal angle.
    if (dominant < quiet * 5 / 4)
        return fallback;

    if (ay > ax)
        return y >= 0 ? 90 : -90;

    return x >= 0 ? 0 : 180;
}
