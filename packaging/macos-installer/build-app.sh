#!/usr/bin/env bash
# Build the Scanly Deploy macOS app, a self-contained installer that
# bootstraps XOVI + AppLoad + Scanly on a vanilla reMarkable Paper Pro.
#
# Steps:
#   1. Ensure the aarch64 Scanly binary + linuxfb plugin are present
#   2. Stage them into Sources/ScanlyDeploy/Resources/payload/
#   3. swift build -c release
#   4. Wrap the binary into Scanly Deploy.app
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
PAYLOAD="$HERE/Sources/ScanlyDeploy/Resources/payload"
# Build outside ~/Desktop so macOS TCC doesn't prompt every launch for
# Desktop folder access. ~/Library/Application Support isn't a protected
# zone, the app runs from there freely.
APP_PARENT="$HOME/Library/Application Support/ScanlyDeploy"
APP_DIR="$APP_PARENT/Scanly Deploy.app"
mkdir -p "$APP_PARENT"

BIN="$REPO/build-rm/scanly"
LINUXFB="$REPO/packaging/appload/scanly/platforms/libqlinuxfb.so"
MANIFEST="$REPO/packaging/appload/scanly/external.manifest.json"
RUNSH="$REPO/packaging/appload/scanly/run.sh"

# Make sure Docker is reachable; the cross-build needs it.
if ! command -v docker >/dev/null 2>&1; then
    echo "docker is required to cross-build the Scanly aarch64 binary."
    echo "Install Docker Desktop and retry."
    exit 1
fi

# Build the SDK image once if missing.
if ! docker image inspect scanly-sdk >/dev/null 2>&1; then
    echo "==> Building scanly-sdk Docker image (one-shot)"
    docker build --platform=linux/arm64 -t scanly-sdk "$REPO/docker"
fi

echo "==> Cross-building Scanly aarch64 (incremental)"
docker run --rm --platform=linux/arm64 -v "$REPO:/src" scanly-sdk \
    bash -lc 'source $SDK_ENV && cmake -B build-rm -S /src && cmake --build build-rm'

# linuxfb plugin only needs to be rebuilt when the Qt SDK version bumps.
if [[ ! -f "$LINUXFB" ]]; then
    echo "==> Building libqlinuxfb.so (first run)"
    "$REPO/packaging/appload/build-linuxfb.sh"
fi

# Sanity check.
for f in "$BIN" "$LINUXFB" "$MANIFEST" "$RUNSH"; do
    [[ -f "$f" ]] || { echo "Missing artefact: $f"; exit 1; }
done

echo "==> Staging payload at $PAYLOAD"
rm -rf "$PAYLOAD"
mkdir -p "$PAYLOAD/scanly/platforms"
cp "$BIN"       "$PAYLOAD/scanly/scanly"
cp "$LINUXFB"   "$PAYLOAD/scanly/platforms/libqlinuxfb.so"
cp "$MANIFEST"  "$PAYLOAD/scanly/external.manifest.json"
cp "$RUNSH"     "$PAYLOAD/scanly/run.sh"
ICON="$REPO/packaging/appload/scanly/icon.png"
if [[ -f "$ICON" ]]; then
    cp "$ICON" "$PAYLOAD/scanly/icon.png"
fi
chmod +x "$PAYLOAD/scanly/scanly" "$PAYLOAD/scanly/run.sh"

echo "==> swift build -c release"
cd "$HERE"
swift build -c release

EXE="$(swift build -c release --show-bin-path)/ScanlyDeploy"

echo "==> Generating app icons"
if [[ ! -f "$HERE/Resources/AppIcon.icns" ]] || [[ "$HERE/Scripts/generate-icons.swift" -nt "$HERE/Resources/AppIcon.icns" ]]; then
    swift "$HERE/Scripts/generate-icons.swift" "$HERE"
fi

echo "==> Assembling .app bundle"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$EXE" "$APP_DIR/Contents/MacOS/ScanlyDeploy"
cp "$HERE/Resources/Info.plist" "$APP_DIR/Contents/Info.plist"
cp "$HERE/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"

# Stage payload at Contents/Resources/payload/scanly/ so Bundle.main can
# find it without going through SwiftPM's Bundle.module, which embeds the
# absolute .build/ path as a hard-coded fallback.
mkdir -p "$APP_DIR/Contents/Resources/payload"
cp -R "$PAYLOAD/scanly" "$APP_DIR/Contents/Resources/payload/"

# SwiftPM emits resources under {bin}/ScanlyDeploy_ScanlyDeploy.bundle.
# Re-pack them into the app's Resources directory.
RES_BUNDLE="$(swift build -c release --show-bin-path)/ScanlyDeploy_ScanlyDeploy.bundle"
if [[ -d "$RES_BUNDLE" ]]; then
    cp -R "$RES_BUNDLE" "$APP_DIR/Contents/Resources/"
fi

# IMPORTANT: do NOT symlink the .app under ~/Desktop. macOS treats the
# launching bundle URL as "on Desktop" when launched via a symlink path,
# which trips Desktop-folder TCC even though the actual bundle lives in
# ~/Library/Application Support. The user must launch from Library.
rm -f "$HERE/build/Scanly Deploy.app" 2>/dev/null || true

echo
echo "Built: $APP_DIR"
echo
echo "Launch with:"
echo "  open '$APP_DIR'"
echo
echo "Or drag it from a Finder window:"
echo "  open '$APP_PARENT'"
