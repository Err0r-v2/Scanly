#!/usr/bin/env bash
# Build libqlinuxfb.so (Qt6 platform plugin) for reMarkable Paper Pro.
#
# Why: the Qt 6.8.2 build shipped on Paper Pro firmware (and in reMarkable's
# Codex SDK) was configured without the linuxfb platform plugin, only
# offscreen / minimal / vnc / epaper are present. The qtfb-shim used by
# rm-appload only hooks /dev/fb0, so it needs an app running under the
# `linuxfb` platform to do anything. We rebuild the plugin from the
# upstream qtbase source tag and ship it inside the AppLoad bundle.
#
# Output: packaging/appload/scanly/platforms/libqlinuxfb.so
set -euo pipefail

QT_TAG="${QT_TAG:-v6.8.2}"
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${HERE}/scanly/platforms"
SRC_DIR="src/plugins/platforms/linuxfb"

mkdir -p "${OUT_DIR}"

if [[ ! -d /tmp/qtbase-linuxfb ]]; then
    echo "[linuxfb] cloning qtbase ${QT_TAG} (sparse)…"
    git clone --depth 1 --branch "${QT_TAG}" --filter=blob:none --sparse \
        https://github.com/qt/qtbase.git /tmp/qtbase-linuxfb
    git -C /tmp/qtbase-linuxfb sparse-checkout set "${SRC_DIR}"
fi

# Copy only the plugin source + our standalone CMakeLists.txt
rm -rf /tmp/qlinuxfb-build
mkdir -p /tmp/qlinuxfb-src
cp /tmp/qtbase-linuxfb/${SRC_DIR}/*.cpp /tmp/qlinuxfb-src/
cp /tmp/qtbase-linuxfb/${SRC_DIR}/*.h   /tmp/qlinuxfb-src/
cp /tmp/qtbase-linuxfb/${SRC_DIR}/linuxfb.json /tmp/qlinuxfb-src/
cp "${HERE}/build-linuxfb/CMakeLists.txt" /tmp/qlinuxfb-src/CMakeLists.txt
patch -d /tmp/qlinuxfb-src -p1 < "${HERE}/build-linuxfb/qlinuxfb-qtfb-update.patch"

# Drop the optional DRM/KMS-only files: the SDK has no KmsSupport.
rm -f /tmp/qlinuxfb-src/qlinuxfbdrmscreen.cpp /tmp/qlinuxfb-src/qlinuxfbdrmscreen.h

docker run --rm --platform=linux/arm64 \
    -v /tmp/qlinuxfb-src:/src \
    -v /tmp/qlinuxfb-build:/build \
    scanly-sdk bash -lc '
        set -e
        source $SDK_ENV
        cmake -B /build -S /src -G "Unix Makefiles"
        cmake --build /build -j
    '

# Plugins land under /build/plugins/platforms/ when built via qt_add_plugin
plugin=$(find /tmp/qlinuxfb-build -name "libqlinuxfb.so" -print -quit)
if [[ -z "$plugin" ]]; then
    echo "[linuxfb] BUILD FAILED, no libqlinuxfb.so produced" >&2
    exit 1
fi

cp "$plugin" "${OUT_DIR}/libqlinuxfb.so"
echo
echo "[linuxfb] OK → ${OUT_DIR}/libqlinuxfb.so"
file "${OUT_DIR}/libqlinuxfb.so"
