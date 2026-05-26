<div align="center">

<img src="https://github.com/Err0r-v2/Scanly/releases/download/v0.1.0/icon.png" width="140" alt="Scanly">

# Scanly

**A manga reader for reMarkable Paper Pro.**

Native Qt 6 / QML · tuned for E Ink Gallery 3 · runs as a tile inside the
official xochitl UI · no account, no ads, no telemetry.

</div>

---

## Install

Grab the macOS installer, plug the tablet in, click **Install everything missing**. That's it.

```
packaging/macos-installer/build-app.sh         # build the installer .app
open ~/Library/Application\ Support/ScanlyDeploy/Scanly\ Deploy.app
```

The installer bootstraps **XOVI**, **AppLoad** and **Scanly** on a fresh
Paper Pro in one click. It also detects what's already installed and only
deploys the missing pieces.

> Linux / Windows users: use the manual deploy path under
> [`packaging/appload/`](packaging/appload/README.md).

## Features

|                            |                                                                                          |
| -------------------------- | ---------------------------------------------------------------------------------------- |
| **Multi-source**           | French (`anime-sama`, `yaoiscan`) · English (`weebcentral`). Toggle per source.          |
| **MangaDex metadata**      | Synopsis, tags, year, hi-res cover. Cached per series.                                   |
| **Offline reader**         | Parallel page downloads (6 concurrent), pre-resized JPEG q88, library = offline shelf.   |
| **Offline mode**           | Disables Wi-Fi on the device (`rfkill`) and falls back to cached chapters only.          |
| **Landscape spread**       | Auto-detects orientation; 2-page side-by-side, single full-screen for double-page panels. |
| **Auto-advance**           | Tap forward on the last page to jump to the next chapter; first pages pre-fetched.       |
| **E-ink tuned**            | Patched `linuxfb` plugin: per-frame waveform (A2 / DU / GC16) + ghost-clean cadence.      |
| **xochitl-style keyboard** | Full-width black panel, QWERTY / AZERTY toggle.                                          |

## Build from source

<details>
<summary><strong>Desktop (macOS, fast iteration)</strong></summary>

```sh
brew install qt cmake
cmake -B build-desktop -DCMAKE_PREFIX_PATH="$(brew --prefix qt)"
cmake --build build-desktop
./build-desktop/scanly
```

Everything except E Ink rendering works: scraping, downloads, MangaDex,
keyboard, Wi-Fi kill (asks for admin on macOS), device stats.

</details>

<details>
<summary><strong>reMarkable Paper Pro (cross-compile via Docker)</strong></summary>

The Codex SDK is fetched automatically from reMarkable's public bucket.

```sh
# Apple Silicon , native aarch64, no Rosetta
docker build --platform=linux/arm64 -t scanly-sdk docker/
docker run --rm -v "$PWD:/src" scanly-sdk \
  bash -lc 'source $SDK_ENV && cmake -B build-rm -S /src && cmake --build build-rm'
```

For Intel hosts, pass `--platform=linux/amd64 --build-arg HOST_ARCH=x86_64`.

The macOS installer (`packaging/macos-installer/build-app.sh`) runs this
step for you and wraps the result into a self-contained `.app`.

</details>

<details>
<summary><strong>Deploy without the installer</strong></summary>

Prereq: XOVI + rm-appload already on the tablet. See
[`packaging/appload/README.md`](packaging/appload/README.md) for the full
recipe.

```sh
packaging/appload/build-linuxfb.sh           # once per Qt SDK bump
packaging/appload/deploy-appload.sh 10.11.99.1
```

</details>

## Architecture

Two layers glued by `QQmlContext` properties exposed in `src/main.cpp`. The
QML module URI is `app.scanly`.

- **C++ core** (`src/`) , sources (ScanMirror, WeebCentral), MangaSourceRouter
  facade, MangaDex metadata, library + downloads (parallel, JPEG-resized
  on save), settings, device sensors, ePaper refresh-mode controller.
- **QML UI** (`qml/`) , pure Qt Quick, sumi-e palette
  (`paper #fbfaf5`, `ink #060606`, `seal #6f180f`). No animations
  (e-ink ghosting).
- **Installer** (`packaging/macos-installer/`) , SwiftUI macOS app, drives
  the system `ssh` / `scp` through `expect` for password auth.

See module headers in `src/` and `qml/` for the per-file contract.

## Credits

Sources scraped: `anime-sama.me`, `yaoiscan.fr`, `weebcentral.com`.
Scanlation group credit shown in-app on every chapter row.

Metadata: [MangaDex](https://api.mangadex.org).
Runtime hosting on device: [XOVI](https://github.com/asivery/xovi)
+ [rm-appload](https://github.com/asivery/rm-appload)
+ [qtfb-shim](https://github.com/asivery/rm-appload) by
[asivery](https://github.com/asivery).

Unofficial third-party application. Not affiliated with reMarkable AS.
