#!/usr/bin/env bash
# Deploy Scanly as an AppLoad external app on a reMarkable Paper Pro.
# Requires XOVI + rmpp-appload already installed on the device.
#
# Usage: packaging/appload/deploy-appload.sh [device-ip] [binary]
set -euo pipefail

DEVICE_IP="${1:-10.11.99.1}"
BINARY="${2:-build-rm/scanly}"
TARGET_DIR="/home/root/xovi/exthome/appload/scanly"
HERE="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -f "$BINARY" ]]; then
    echo "Binary not found: $BINARY"
    echo "Cross-build first:"
    echo "  docker run --rm --platform=linux/arm64 -v \$PWD:/src scanly-sdk \\"
    echo "    bash -lc 'source \$SDK_ENV && cmake -B build-rm -S /src && cmake --build build-rm'"
    exit 1
fi

echo "Deploying Scanly AppLoad bundle to root@${DEVICE_IP}:${TARGET_DIR}..."
ssh "root@${DEVICE_IP}" "mkdir -p '${TARGET_DIR}'"

# Binary
scp "$BINARY" "root@${DEVICE_IP}:${TARGET_DIR}/scanly.new"

# Manifest
scp "${HERE}/scanly/external.manifest.json" \
    "root@${DEVICE_IP}:${TARGET_DIR}/external.manifest.json"

# Runtime wrapper. AppLoad's qtfb integration needs the external process to
# preload qtfb-shim so linuxfb /dev/fb0 access is intercepted.
scp "${HERE}/scanly/run.sh" "root@${DEVICE_IP}:${TARGET_DIR}/run.sh"

# Qt platform plugin (linuxfb). Built by packaging/appload/build-linuxfb.sh
# and required because reMarkable's stock Qt 6.8.2 omits the linuxfb plugin,
# which qtfb-shim needs to intercept /dev/fb0 access.
if [[ -f "${HERE}/scanly/platforms/libqlinuxfb.so" ]]; then
    ssh "root@${DEVICE_IP}" "mkdir -p '${TARGET_DIR}/platforms'"
    scp "${HERE}/scanly/platforms/libqlinuxfb.so" \
        "root@${DEVICE_IP}:${TARGET_DIR}/platforms/libqlinuxfb.so"
else
    echo "Qt linuxfb platform plugin missing: ${HERE}/scanly/platforms/libqlinuxfb.so" >&2
    echo "Run packaging/appload/build-linuxfb.sh first." >&2
    exit 1
fi

# Optional icon, drop a 512×512 PNG in packaging/appload/scanly/icon.png
if [[ -f "${HERE}/scanly/icon.png" ]]; then
    scp "${HERE}/scanly/icon.png" "root@${DEVICE_IP}:${TARGET_DIR}/icon.png"
fi

# Atomic swap so a running instance isn't trampled mid-deploy.
ssh "root@${DEVICE_IP}" \
    "chmod +x '${TARGET_DIR}/scanly.new' '${TARGET_DIR}/run.sh' && mv -f '${TARGET_DIR}/scanly.new' '${TARGET_DIR}/scanly'"

echo
echo "Done. The Scanly tile should now appear in xochitl's app launcher."
echo "Tap to open; long-press for windowed mode."
echo
echo "If nothing appears, restart AppLoad or reboot xochitl:"
echo "  ssh root@${DEVICE_IP} 'systemctl restart xochitl'"
