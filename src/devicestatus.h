#pragma once

#include <QObject>
#include <QTimer>

class DeviceStatus : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int batteryPercent READ batteryPercent NOTIFY changed)
    Q_PROPERTY(bool batteryCharging READ batteryCharging NOTIFY changed)
    Q_PROPERTY(bool online READ online NOTIFY changed)
    Q_PROPERTY(bool landscape READ landscape NOTIFY changed)
    Q_PROPERTY(int rotationAngle READ rotationAngle NOTIFY changed)
    Q_PROPERTY(qint64 storageBytesTotal READ storageBytesTotal NOTIFY changed)
    Q_PROPERTY(qint64 storageBytesFree READ storageBytesFree NOTIFY changed)
    Q_PROPERTY(qint64 storageBytesUsed READ storageBytesUsed NOTIFY changed)
    Q_PROPERTY(QString currentTime READ currentTime NOTIFY tick)

public:
    explicit DeviceStatus(QObject *parent = nullptr);

    int batteryPercent() const { return m_battery; }
    bool batteryCharging() const { return m_charging; }
    bool online() const { return m_online; }
    bool landscape() const { return m_landscape; }
    int rotationAngle() const { return m_rotationAngle; }
    qint64 storageBytesTotal() const { return m_storageTotal; }
    qint64 storageBytesFree() const { return m_storageFree; }
    qint64 storageBytesUsed() const { return m_storageTotal > m_storageFree ? m_storageTotal - m_storageFree : 0; }
    QString currentTime() const;

signals:
    void changed();
    void tick();

private:
    QTimer m_statusTimer;
    QTimer m_orientationTimer;
    QTimer m_clockTimer;
    int m_battery = -1;
    bool m_charging = false;
    bool m_online = true;
    bool m_landscape = false;
    int m_rotationAngle = 0;
    qint64 m_storageTotal = 0;
    qint64 m_storageFree = 0;

    void refresh();
    void readBattery();
    void readBatteryMac();
    void readBatteryLinux();
    void readStorage();
    bool readOnline() const;
    bool readOnlineLinux() const;
    void refreshOrientation();
    int readRotationAngle(int fallback) const;
    int readRotationAngleLinux(int fallback) const;
};
