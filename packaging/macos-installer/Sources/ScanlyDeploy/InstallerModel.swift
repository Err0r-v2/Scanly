import Foundation
import SwiftUI

enum StepStatus: Equatable {
    case unknown
    case missing
    case installed
    case working(String)            // active operation label
    case failed(String)
}

enum DeviceStatus: Equatable {
    case unknown
    case offline
    case online
    case authChecking
    case authed
    case authFailed
}

@MainActor
final class InstallerModel: ObservableObject {
    // Connection
    @Published var host: String = "10.11.99.1"
    @Published var password: String = ""
    @Published var deviceStatus: DeviceStatus = .unknown
    @Published var deviceMeta: String = "Plug your reMarkable Paper Pro via USB."

    // Components
    @Published var xoviStatus:    StepStatus = .unknown
    @Published var appLoadStatus: StepStatus = .unknown
    @Published var scanlyStatus:  StepStatus = .unknown

    @Published var log: String = ""
    // Transient banner shown while xochitl is bouncing.
    @Published var notice: String? = nil

    @Published var showingPassword = false
    @Published var isBusy = false

    private let ssh = SSHClient()
    private var monitorTask: Task<Void, Never>?

    private var target: SSHTarget {
        SSHTarget(host: host, user: "root", password: password)
    }

    init() {
        startMonitoring()
    }

    func startMonitoring() {
        monitorTask?.cancel()
        monitorTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { return }
                let alive = await SSHClient.reachable(self.host)
                await MainActor.run {
                    if alive {
                        if self.deviceStatus == .offline || self.deviceStatus == .unknown {
                            self.deviceStatus = .online
                            self.deviceMeta = "reMarkable detected at \(self.host)."
                        }
                    } else {
                        self.deviceStatus = .offline
                        self.deviceMeta = "Searching… plug USB and enable Developer mode."
                        self.xoviStatus = .unknown
                        self.appLoadStatus = .unknown
                        self.scanlyStatus = .unknown
                    }
                }
                try? await Task.sleep(nanoseconds: 2_500_000_000)
            }
        }
    }

    func probe() async {
        guard !password.isEmpty else {
            await MainActor.run { self.showingPassword = true }
            return
        }
        await MainActor.run { self.appendLog("→ probing device state") }
        // sshd can be flaky for a second right after xochitl bounces.
        var lastError: Error? = nil
        for attempt in 1...4 {
            do {
                // Check the live LD_PRELOAD mapping, not just file presence:
                // a half-install leaves xovi.so on disk but unloaded.
                let out = try await ssh.run(target, command:
                    "xpid=$(pidof xochitl); " +
                    "if [ -f /home/root/xovi/xovi.so ] && [ -n \"$xpid\" ] && grep -q xovi.so /proc/$xpid/maps 2>/dev/null; then echo XOVI:1; else echo XOVI:0; fi; " +
                    "if [ -f /home/root/xovi/extensions.d/appload.so ] && [ -n \"$xpid\" ] && grep -q appload.so /proc/$xpid/maps 2>/dev/null; then echo APPLOAD:1; else echo APPLOAD:0; fi; " +
                    "[ -f /home/root/xovi/exthome/appload/shims/qtfb-shim.so ] && echo SHIM:1 || echo SHIM:0; " +
                    "[ -x /home/root/xovi/exthome/appload/scanly/scanly ] && echo SCANLY:1 || echo SCANLY:0"
                )
                await MainActor.run {
                    self.deviceStatus = .authed
                    self.xoviStatus = out.contains("XOVI:1") ? .installed : .missing
                    let appLoadOK = out.contains("APPLOAD:1") && out.contains("SHIM:1")
                    self.appLoadStatus = appLoadOK ? .installed : .missing
                    self.scanlyStatus = out.contains("SCANLY:1") ? .installed : .missing
                    self.appendLog("← XOVI \(self.xoviStatus.label), AppLoad \(self.appLoadStatus.label), Scanly \(self.scanlyStatus.label)")
                }
                return
            } catch let err as SSHError {
                lastError = err
                if case .authFailed = err {
                    await MainActor.run {
                        self.appendLog("× \(err.localizedDescription)")
                        self.deviceStatus = .authFailed
                        self.showingPassword = true
                    }
                    return
                }
                if attempt < 4 {
                    await MainActor.run { self.appendLog("(probe attempt \(attempt) failed, retrying in 2 s)") }
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                }
            } catch {
                lastError = error
                if attempt < 4 {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                }
            }
        }
        if let err = lastError {
            await MainActor.run { self.appendLog("× probe gave up: \(err.localizedDescription)") }
        }
    }

    private func sink() -> Installer.Sink {
        Installer.Sink(
            log: { [weak self] line in
                Task { @MainActor in self?.appendLog(line) }
            },
            notice: { [weak self] msg in
                Task { @MainActor in self?.notice = msg }
            }
        )
    }

    func installXOVI() async {
        await runStep(label: "XOVI", set: { self.xoviStatus = $0 }) {
            try await Installer.installXOVI(ssh: self.ssh, target: self.target, sink: self.sink())
        }
    }

    func installAppLoad() async {
        await runStep(label: "AppLoad", set: { self.appLoadStatus = $0 }) {
            try await Installer.installAppLoad(ssh: self.ssh, target: self.target, sink: self.sink())
        }
    }

    func installScanly() async {
        await runStep(label: "Scanly", set: { self.scanlyStatus = $0 }) {
            try await Installer.deployScanly(ssh: self.ssh, target: self.target, sink: self.sink())
        }
    }

    func restartXochitl() async {
        guard !password.isEmpty else {
            await MainActor.run { self.showingPassword = true }
            return
        }
        await MainActor.run {
            self.isBusy = true
            self.notice = "Reloading XOVI - xochitl is restarting. Enter the unlock code on the tablet if prompted."
            self.appendLog("→ restarting xochitl (XOVI reload)")
        }
        do {
            // Background it so SSH doesn't die with xochitl.
            _ = try await ssh.run(target, command:
                "nohup sh -c 'systemctl restart xochitl' >/dev/null 2>&1 &"
            )
        } catch {
            await MainActor.run {
                self.appendLog("× restart: \(error.localizedDescription)")
            }
        }
        // Wait for xochitl to come back, then re-probe.
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        await MainActor.run {
            self.notice = nil
            self.isBusy = false
        }
        await probe()
    }

    func installEverythingNeeded() async {
        if xoviStatus    != .installed { await installXOVI()    }
        if appLoadStatus != .installed { await installAppLoad() }
        if scanlyStatus  != .installed { await installScanly()  }
        await probe()
    }

    private func runStep(
        label: String,
        set: @MainActor (StepStatus) -> Void,
        op: @escaping () async throws -> Void
    ) async {
        guard !password.isEmpty else {
            await MainActor.run { self.showingPassword = true }
            return
        }
        await MainActor.run {
            set(.working("Installing…"))
            self.isBusy = true
            self.appendLog("→ \(label): starting")
        }
        do {
            try await op()
            await MainActor.run {
                set(.installed)
                self.appendLog("✓ \(label): done")
                self.isBusy = false
            }
        } catch {
            await MainActor.run {
                set(.failed(error.localizedDescription))
                self.appendLog("× \(label): \(error.localizedDescription)")
                self.isBusy = false
            }
        }
        // Re-probe to catch the truth in case ssh dropped mid-install.
        await probe()
    }

    // Buffered, batched log writes — rebuild_hashtable spews hundreds of
    // lines/sec and SwiftUI can't keep up redrawing on every line.
    private var pendingLog: String = ""
    private var flushTask: Task<Void, Never>? = nil
    private static let logCap = 64 * 1024  // ~64 KB == plenty for any install

    func appendLog(_ line: String) {
        let stamp = Self.timestamp()
        pendingLog.append("[\(stamp)] \(line)\n")
        if flushTask == nil {
            flushTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: 100_000_000)
                await MainActor.run { self?.flushLog() }
            }
        }
    }

    private func flushLog() {
        defer { flushTask = nil }
        guard !pendingLog.isEmpty else { return }
        var next = log + pendingLog
        if next.count > Self.logCap {
            let drop = next.count - Self.logCap
            let i = next.index(next.startIndex, offsetBy: drop)
            // Trim to the next newline so we don't slice a line in half.
            if let nl = next[i...].firstIndex(of: "\n") {
                next = String(next[next.index(after: nl)...])
            } else {
                next = String(next[i...])
            }
        }
        log = next
        pendingLog = ""
    }

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()
    private static func timestamp() -> String { formatter.string(from: Date()) }
}

extension StepStatus {
    var label: String {
        switch self {
        case .unknown:           return ", "
        case .missing:           return "missing"
        case .installed:         return "installed"
        case .working(let s):    return s
        case .failed(let s):     return "failed: \(s)"
        }
    }
}
