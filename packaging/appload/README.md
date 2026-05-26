# AppLoad integration

Scanly runs as an [rm-appload](https://github.com/asivery/rm-appload)
external application on Paper Pro, appearing as a tile in xochitl's app
launcher.

## Prerequisites on the device

1. **XOVI** installed (see [asivery/xovi](https://github.com/asivery/xovi)).
2. **rm-appload** extension installed under XOVI, with
   `qtfb-shim.so` at `/home/root/xovi/exthome/appload/shims/`.
3. Scanly's bundled `libqlinuxfb.so` platform plugin. Build it once with:

```sh
packaging/appload/build-linuxfb.sh
```

## Deploy

```sh
# Cross-build the aarch64 binary
docker run --rm --platform=linux/arm64 -v "$PWD:/src" scanly-sdk \
  bash -lc 'source $SDK_ENV && cmake -B build-rm -S /src && cmake --build build-rm'

# Push the bundle + binary onto the device
packaging/appload/deploy-appload.sh 10.11.99.1
```

The bundle lives at `/home/root/xovi/exthome/appload/scanly/`:

```
scanly/
├── external.manifest.json   # declares the external app to AppLoad
├── run.sh                   # preloads qtfb-shim.so, sets env, execs scanly
├── scanly                   # aarch64 binary
├── platforms/
│   └── libqlinuxfb.so       # patched Qt linuxfb platform plugin
└── icon.png                 # optional 512×512 launcher icon
```

The Scanly tile appears in xochitl's app launcher. Tap to open fullscreen;
long-press for windowed mode.

## How it works

`run.sh` preloads `qtfb-shim.so` before exec'ing scanly. The manifest sets
`QT_QPA_PLATFORM=linuxfb:fb=/dev/fb0` and points Qt at the bundled
`platforms/libqlinuxfb.so`. The shim runs in `RGB565` mode on Paper Pro's
1620×2160 framebuffer and starts in `CONTENT` display mode.

The patched linuxfb plugin reads `/tmp/scanly-qtfb-default-mode` on every
flush to pick a per-frame waveform (the Settings screen mode controls this
file while the reader is open), and consumes a one-shot
`/tmp/scanly-qtfb-force-full` flag to trigger a `UPDATE_MODE_FULL` refresh
for the ghost-clean cadence.

At startup main.cpp also writes `OrientationLocked=true` to
`/home/root/.config/remarkable/xochitl.conf`, so xochitl stops auto-rotating
the AppLoad window when the user holds the tablet sideways. Scanly then
drives its own landscape layout (2-page spread, rotated reader surface)
from the accelerometer. The previous value is restored on exit.
