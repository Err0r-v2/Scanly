# Scanly Deploy (macOS installer)

A native macOS app that installs Scanly on a **vanilla** reMarkable Paper Pro , 
no Docker, no SDK, no command line required of the end user.

## What it does

Detects what's already on the tablet and offers to install the missing pieces,
in order:

1. **XOVI**, the LD_PRELOAD injection framework that patches `xochitl`.
2. **AppLoad**, XOVI extension that exposes external apps to the launcher,
   bundled with `qtfb-shim.so` for framebuffer interception.
3. **Scanly**, the reader binary, manifest, `libqlinuxfb.so` plugin, `run.sh`.

XOVI and AppLoad are fetched on demand from their GitHub Releases
(`asivery/rm-xovi-extensions` and `asivery/rm-appload`) and cached under
`~/Library/Caches/app.scanly.deploy/`. The Scanly payload is **bundled inside
the .app**, so the installer can deploy offline once built.

## Build

```sh
# 1. Cross-build the aarch64 Scanly binary (Docker required to BUILD; the
#    .app itself has no Docker dependency for end users).
docker run --rm --platform=linux/arm64 -v "$PWD:/src" scanly-sdk \
  bash -lc 'source $SDK_ENV && cmake -B build-rm -S /src && cmake --build build-rm'

# 2. Build the macOS app.
packaging/macos-installer/build-app.sh
```

Output: `packaging/macos-installer/build/Scanly Deploy.app`.

## Run

```sh
open 'packaging/macos-installer/build/Scanly Deploy.app'
```

The app polls `10.11.99.1:22` continuously. Plug the tablet in USB and enable
**Settings → Storage → Developer mode** to expose `sshd` and the root password.

Click the key icon to enter the developer password. The app then probes XOVI /
AppLoad / Scanly state and surfaces an **Install** button for each missing
component, plus an **Install everything missing** primary action.

## Architecture

Single SwiftPM target, ~6 files of Swift:

- `ScanlyDeployApp.swift`, `@main`, single `Window` scene.
- `Theme.swift`, sumi-e palette matching the app it deploys.
- `ContentView.swift`, two-pane layout: steps left, console right.
- `Views/`, `DeviceCard`, `StepRow`, `LogPane`.
- `InstallerModel.swift`, `@MainActor` `ObservableObject` driving the UI
  state machine, plus the reachability poller.
- `SSHClient.swift`, wraps `/usr/bin/ssh` and `/usr/bin/scp` through
  `/usr/bin/expect` (all three are pre-installed on every macOS).
- `Installer.swift`, the actual recipes (download release tarball, scp
  into `/home/root/xovi/...`, run `rebuild_hashtable` / `start` /
  `systemctl restart xochitl`, deploy bundled Scanly payload).

## End-user requirements

- macOS 13+ (SwiftUI / `Window` scene).
- USB cable, USB-C data line (not a charger-only cable).
- reMarkable Paper Pro with **Developer mode** enabled.

Nothing else. No `brew`, no Docker, no manual XOVI install.
