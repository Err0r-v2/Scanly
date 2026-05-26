import Foundation

enum Installer {

    struct Sink: Sendable {
        let log: @Sendable (String) -> Void
        let notice: @Sendable (String?) -> Void
    }

    static let xoviTarballURL = URL(string:
        "https://github.com/asivery/rm-xovi-extensions/releases/latest/download/xovi-aarch64.tar.gz")!

    static let appLoadZipURL = URL(string:
        "https://github.com/asivery/rm-appload/releases/latest/download/appload-aarch64.zip")!

    static let cacheDir: URL = {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("app.scanly.deploy")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    static func installXOVI(
        ssh: SSHClient,
        target: SSHTarget,
        sink: Sink
    ) async throws {
        let log = sink.log
        log("downloading XOVI bundle…")
        let local = try await download(xoviTarballURL, named: "xovi-aarch64.tar.gz", log: log)

        log("uploading XOVI tarball to /tmp/")
        try await ssh.upload(target, localPath: local.path, remotePath: "/tmp/xovi.tar.gz", onLog: log)

        log("extracting tarball…")
        _ = try await ssh.run(target, command:
            "set -e; " +
            // Tarball has its own xovi/ at the root, extract one level up.
            "rm -rf /home/root/xovi && " +
            "tar -xzf /tmp/xovi.tar.gz -C /home/root/ && " +
            "rm -f /tmp/xovi.tar.gz && " +
            "chmod +x /home/root/xovi/start /home/root/xovi/debug /home/root/xovi/rebuild_hashtable 2>/dev/null || true",
            onLog: log
        )

        // rebuild_hashtable bounces xochitl, which kicks the user back to
        // the lock screen — they need to be there to type the passcode.
        sink.notice("The tablet is about to restart. Keep it awake (tap the screen every now and then) and enter your passcode if prompted, otherwise the install may stall.")
        log("running rebuild_hashtable (~30 s, xochitl will restart)…")
        do {
            // Mute the firehose of xochitl QML warnings rebuild_hashtable echoes.
            _ = try await ssh.run(target, command:
                "/home/root/xovi/rebuild_hashtable < /dev/null",
                onLog: filterRebuildOutput(log)
            )
        } catch SSHError.notReachable {
            log("ssh dropped during rebuild, retrying once xochitl is back up")
        }
        try await waitForXochitl(ssh: ssh, target: target, log: log)

        log("registering XOVI in xochitl.service…")
        do {
            _ = try await ssh.run(target, command: "/home/root/xovi/start", onLog: log)
        } catch SSHError.notReachable {
            log("ssh dropped during start, retrying once xochitl is back up")
        }
        try await waitForXochitl(ssh: ssh, target: target, log: log)

        // start can silently fail to install the drop-in (SSH cut, tmpfs
        // race) — confirm xovi.so is actually in xochitl, retry once if not.
        for attempt in 1...2 {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            let check = (try? await ssh.run(target, command:
                "p=$(pidof xochitl); [ -n \"$p\" ] && grep -q xovi.so /proc/$p/maps 2>/dev/null && echo XOVI-LOADED || echo XOVI-MISSING"
            )) ?? ""
            if check.contains("XOVI-LOADED") { break }
            if attempt == 1 {
                log("xovi.so not in xochitl yet, re-running start…")
                _ = try? await ssh.run(target, command: "/home/root/xovi/start", onLog: log)
                try await waitForXochitl(ssh: ssh, target: target, log: log)
            } else {
                throw SSHError.launch("XOVI installed but not loaded into xochitl. Try Restart XOVI.")
            }
        }
        sink.notice(nil)
    }

    static func installAppLoad(
        ssh: SSHClient,
        target: SSHTarget,
        sink: Sink
    ) async throws {
        let log = sink.log
        log("downloading AppLoad…")
        let zip = try await download(appLoadZipURL, named: "appload-aarch64.zip", log: log)
        let extractDir = cacheDir.appendingPathComponent("appload-extracted")
        try? FileManager.default.removeItem(at: extractDir)
        try FileManager.default.createDirectory(at: extractDir, withIntermediateDirectories: true)
        try await runLocal("/usr/bin/unzip", ["-q", "-o", zip.path, "-d", extractDir.path])
        let appload = extractDir.appendingPathComponent("appload.so")
        let shim    = extractDir.appendingPathComponent("shims/qtfb-shim.so")
        guard FileManager.default.fileExists(atPath: appload.path),
              FileManager.default.fileExists(atPath: shim.path) else {
            throw SSHError.launch("AppLoad zip layout changed, missing appload.so or shims/qtfb-shim.so")
        }

        _ = try await ssh.run(target, command:
            "mkdir -p /home/root/xovi/extensions.d /home/root/xovi/exthome/appload/shims",
            onLog: log
        )
        log("uploading appload.so…")
        try await ssh.upload(target, localPath: appload.path,
                             remotePath: "/home/root/xovi/extensions.d/appload.so",
                             onLog: log)
        log("uploading qtfb-shim.so…")
        try await ssh.upload(target, localPath: shim.path,
                             remotePath: "/home/root/xovi/exthome/appload/shims/qtfb-shim.so",
                             onLog: log)

        sink.notice("xochitl is restarting, enter the unlock code on the tablet if prompted.")
        log("restarting xochitl to load the extension…")
        do {
            _ = try await ssh.run(target, command: "systemctl restart xochitl", onLog: log)
        } catch SSHError.notReachable {
            log("ssh dropped during restart, retrying once xochitl is back up")
        }
        try await waitForXochitl(ssh: ssh, target: target, log: log)
        sink.notice(nil)
    }

    static func deployScanly(
        ssh: SSHClient,
        target: SSHTarget,
        sink: Sink
    ) async throws {
        let log = sink.log
        // Bundle.main, not Bundle.module: SwiftPM bakes an absolute .build/
        // path into Bundle.module which trips Desktop TCC.
        guard let resRoot = Bundle.main.resourceURL else {
            throw SSHError.launch("App bundle has no resource directory.")
        }
        let payloadDir = resRoot.appendingPathComponent("payload/scanly")
        guard FileManager.default.fileExists(atPath: payloadDir.appendingPathComponent("scanly").path) else {
            throw SSHError.launch("Scanly payload missing, rebuild with build-app.sh.")
        }

        let target_dir = "/home/root/xovi/exthome/appload/scanly"
        _ = try await ssh.run(target, command: "mkdir -p \(target_dir)/platforms", onLog: log)

        let bin     = payloadDir.appendingPathComponent("scanly").path
        let plugin  = payloadDir.appendingPathComponent("platforms/libqlinuxfb.so").path
        let mani    = payloadDir.appendingPathComponent("external.manifest.json").path
        let runsh   = payloadDir.appendingPathComponent("run.sh").path

        log("uploading Scanly binary (\(humanSize(bin)))…")
        try await ssh.upload(target, localPath: bin,    remotePath: "\(target_dir)/scanly.new", onLog: log)
        log("uploading libqlinuxfb.so…")
        try await ssh.upload(target, localPath: plugin, remotePath: "\(target_dir)/platforms/libqlinuxfb.so", onLog: log)
        log("uploading manifest + run.sh…")
        try await ssh.upload(target, localPath: mani,   remotePath: "\(target_dir)/external.manifest.json", onLog: log)
        try await ssh.upload(target, localPath: runsh,  remotePath: "\(target_dir)/run.sh", onLog: log)

        // Optional 512x512 launcher tile. AppLoad picks it up by convention
        // from icon.png alongside the manifest.
        let icon = payloadDir.appendingPathComponent("icon.png")
        if FileManager.default.fileExists(atPath: icon.path) {
            log("uploading icon.png…")
            try await ssh.upload(target, localPath: icon.path,
                                 remotePath: "\(target_dir)/icon.png", onLog: log)
        }

        _ = try await ssh.run(target, command:
            "chmod +x \(target_dir)/scanly.new \(target_dir)/run.sh && " +
            "mv -f \(target_dir)/scanly.new \(target_dir)/scanly",
            onLog: log
        )
    }

    // Poll pidof until xochitl is back, max 60s.
    private static func waitForXochitl(
        ssh: SSHClient,
        target: SSHTarget,
        log: @Sendable @escaping (String) -> Void
    ) async throws {
        let deadline = Date().addingTimeInterval(60)
        while Date() < deadline {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            do {
                let out = try await ssh.run(target, command:
                    "pidof xochitl >/dev/null 2>&1 && echo UP || echo DOWN",
                    onLog: { _ in }
                )
                if out.contains("UP") {
                    log("xochitl is back up")
                    return
                }
            } catch {
                // sshd unreachable for a moment, keep waiting.
            }
        }
        log("xochitl didn't come back in 60 s, continuing anyway")
    }

    // Drop xochitl QML noise, keep only the rebuild_hashtable signal lines.
    private static func filterRebuildOutput(
        _ log: @escaping @Sendable (String) -> Void
    ) -> @Sendable (String) -> Void {
        return { line in
            var clean = line
            while let r = clean.range(of: "\u{1B}[", options: .literal) {
                if let end = clean[r.upperBound...].firstIndex(where: { $0 == "m" }) {
                    clean.removeSubrange(r.lowerBound...end)
                } else { break }
            }
            let trimmed = clean.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { return }
            let keep =
                trimmed.contains("[qmldiff]") ||
                trimmed.contains("Found expected output") ||
                trimmed.contains("Stopping the GUI") ||
                trimmed.contains("hashtable") ||
                trimmed.hasPrefix("We will now") ||
                trimmed.hasPrefix("Output:")
            if keep { log(trimmed) }
        }
    }

    private static func runLocal(_ path: String, _ args: [String]) async throws {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: path)
        p.arguments = args
        try p.run()
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            p.terminationHandler = { _ in c.resume() }
        }
        if p.terminationStatus != 0 {
            throw SSHError.launch("\(path) exited \(p.terminationStatus)")
        }
    }

    private static func download(
        _ url: URL,
        named name: String,
        log: @escaping @Sendable (String) -> Void
    ) async throws -> URL {
        let cached = cacheDir.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: cached.path) {
            log("using cached \(name)")
            return cached
        }
        let (tmp, resp) = try await URLSession.shared.download(from: url)
        if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw SSHError.launch("download \(name) → HTTP \(http.statusCode)")
        }
        try? FileManager.default.removeItem(at: cached)
        try FileManager.default.moveItem(at: tmp, to: cached)
        log("cached \(name)")
        return cached
    }

    private static func humanSize(_ path: String) -> String {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path),
              let n = attrs[.size] as? Int else { return "?" }
        let mb = Double(n) / (1024.0 * 1024.0)
        return String(format: "%.1f MB", mb)
    }
}
