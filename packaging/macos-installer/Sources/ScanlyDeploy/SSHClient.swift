import Foundation

// Wraps system ssh/scp via expect, expect handles the interactive
// password prompt ssh refuses to read from stdin.
struct SSHTarget {
    var host: String = "10.11.99.1"
    var user: String = "root"
    var password: String = ""
    var port: Int = 22

    // Per-app known_hosts and no host-key prompt — a re-flashed device
    // shouldn't break the installer.
    func sshOpts() -> [String] {
        let kh = SSHClient.knownHostsPath
        return [
            "-o", "StrictHostKeyChecking=no",
            "-o", "UserKnownHostsFile=\(kh)",
            "-o", "ConnectTimeout=4",
            "-o", "ServerAliveInterval=10",
            "-p", String(port),
        ]
    }
}

enum SSHError: LocalizedError {
    case timeout
    case authFailed
    case notReachable
    case remote(code: Int32, stderr: String)
    case launch(String)

    var errorDescription: String? {
        switch self {
        case .timeout:                 return "Timed out waiting for the reMarkable."
        case .authFailed:              return "Wrong password (or root login disabled, enable Developer Mode)."
        case .notReachable:            return "Can't reach the reMarkable at this address."
        case .remote(let c, let e):    return "Remote command failed (exit \(c)). \(e)"
        case .launch(let m):           return "Could not launch SSH: \(m)"
        }
    }
}

actor SSHClient {
    static let knownHostsPath: String = {
        let dir = (NSHomeDirectory() as NSString)
            .appendingPathComponent("Library/Application Support/ScanlyDeploy")
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        return (dir as NSString).appendingPathComponent("known_hosts")
    }()

    // TCP connect probe, true if the SSH port is reachable in `timeout`.
    static func reachable(_ host: String, port: Int = 22, timeout: TimeInterval = 1.5) async -> Bool {
        await Task.detached(priority: .utility) { () -> Bool in
            let s = socket(AF_INET, SOCK_STREAM, 0)
            guard s >= 0 else { return false }
            defer { close(s) }
            var addr = sockaddr_in()
            addr.sin_family = sa_family_t(AF_INET)
            addr.sin_port = in_port_t(UInt16(port).bigEndian)
            inet_pton(AF_INET, host, &addr.sin_addr)
            var tv = timeval(tv_sec: Int(timeout), tv_usec: 0)
            setsockopt(s, SOL_SOCKET, SO_SNDTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))
            setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))
            let r = withUnsafePointer(to: &addr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    connect(s, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
                }
            }
            return r == 0
        }.value
    }

    func run(
        _ target: SSHTarget,
        command: String,
        onLog: @escaping @Sendable (String) -> Void = { _ in }
    ) async throws -> String {
        let args = target.sshOpts() + ["\(target.user)@\(target.host)", command]
        return try await runWithExpect(
            binary: "/usr/bin/ssh",
            args: args,
            password: target.password,
            onLog: onLog
        )
    }

    func upload(
        _ target: SSHTarget,
        localPath: String,
        remotePath: String,
        onLog: @escaping @Sendable (String) -> Void = { _ in }
    ) async throws {
        let opts = target.sshOpts().map { $0 == "-p" ? "-P" : $0 }  // scp uses -P
        let args = opts + [localPath, "\(target.user)@\(target.host):\(remotePath)"]
        _ = try await runWithExpect(
            binary: "/usr/bin/scp",
            args: args,
            password: target.password,
            onLog: onLog
        )
    }

    func uploadDir(
        _ target: SSHTarget,
        localDir: String,
        remoteParent: String,
        onLog: @escaping @Sendable (String) -> Void = { _ in }
    ) async throws {
        let opts = (["-r"] + target.sshOpts()).map { $0 == "-p" ? "-P" : $0 }
        let args = opts + [localDir, "\(target.user)@\(target.host):\(remoteParent)"]
        _ = try await runWithExpect(
            binary: "/usr/bin/scp",
            args: args,
            password: target.password,
            onLog: onLog
        )
    }

    private func runWithExpect(
        binary: String,
        args: [String],
        password: String,
        onLog: @escaping @Sendable (String) -> Void
    ) async throws -> String {
        let script = Self.expectScript(binary: binary, args: args)
        let scriptURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("scanly-deploy-\(UUID().uuidString).expect")
        try script.write(to: scriptURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: scriptURL) }

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/expect")
        proc.arguments = ["-f", scriptURL.path]
        var env = ProcessInfo.processInfo.environment
        env["SCANLY_DEPLOY_PASSWORD"] = password
        proc.environment = env

        let outPipe = Pipe()
        let errPipe = Pipe()
        proc.standardOutput = outPipe
        proc.standardError = errPipe

        let buffer = LineBuffer(onLog: onLog)
        outPipe.fileHandleForReading.readabilityHandler = { h in
            let d = h.availableData
            if d.isEmpty { return }
            buffer.feed(d)
        }
        errPipe.fileHandleForReading.readabilityHandler = { h in
            let d = h.availableData
            if d.isEmpty { return }
            buffer.feed(d)
        }

        do {
            try proc.run()
        } catch {
            throw SSHError.launch(error.localizedDescription)
        }

        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            proc.terminationHandler = { _ in cont.resume() }
        }

        outPipe.fileHandleForReading.readabilityHandler = nil
        errPipe.fileHandleForReading.readabilityHandler = nil
        buffer.flush()

        let combined = buffer.allText
        switch proc.terminationStatus {
        case 0:           return combined
        case 5, 6:        throw SSHError.authFailed
        case 124, 255:    throw SSHError.notReachable
        default:          throw SSHError.remote(code: proc.terminationStatus, stderr: combined)
        }
    }

    private static func expectScript(binary: String, args: [String]) -> String {
        let argv = ([binary] + args).map { "{\($0)}" }.joined(separator: " ")
        return """
        #!/usr/bin/env expect -f
        log_user 1
        set timeout 90
        set password $env(SCANLY_DEPLOY_PASSWORD)
        set argv_list [list \(argv)]
        eval spawn -noecho $argv_list
        expect {
            -re "(?i)password:" {
                send -- "$password\\r"
                exp_continue
            }
            -re "(?i)passphrase" {
                send -- "$password\\r"
                exp_continue
            }
            -re "(yes/no)" {
                send -- "yes\\r"
                exp_continue
            }
            -re "Permission denied" {
                exit 5
            }
            -re "Host key verification failed" {
                exit 6
            }
            timeout {
                exit 124
            }
            eof
        }
        catch wait result
        exit [lindex $result 3]
        """
    }
}

final class LineBuffer: @unchecked Sendable {
    private var partial = Data()
    private(set) var allText: String = ""
    private let onLog: @Sendable (String) -> Void
    private let lock = NSLock()

    init(onLog: @escaping @Sendable (String) -> Void) {
        self.onLog = onLog
    }
    func feed(_ data: Data) {
        lock.lock(); defer { lock.unlock() }
        partial.append(data)
        while let nl = partial.firstIndex(of: 0x0a) {
            let lineData = partial.prefix(upTo: nl)
            partial.removeSubrange(partial.startIndex...nl)
            if let line = String(data: lineData, encoding: .utf8) {
                allText += line + "\n"
                onLog(line)
            }
        }
    }
    func flush() {
        lock.lock(); defer { lock.unlock() }
        if !partial.isEmpty, let s = String(data: partial, encoding: .utf8) {
            allText += s
            onLog(s)
            partial.removeAll()
        }
    }
}
