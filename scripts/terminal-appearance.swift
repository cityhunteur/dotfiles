// macOS clients with file-based themes: Starship, Helix, K9s and Codex CLI.
import AppKit
import Darwin
import Foundation

let args = Array(CommandLine.arguments.dropFirst())
guard args.count == 4, ["watch", "system", "light", "dark"].contains(args[0]) else {
    fputs("Usage: terminal-appearance watch|system|light|dark source-config user-config k9s-dir\n", stderr)
    exit(64)
}
let files = FileManager.default
let source = URL(fileURLWithPath: args[1], isDirectory: true)
let config = URL(fileURLWithPath: args[2], isDirectory: true)
let k9s = URL(fileURLWithPath: args[3], isDirectory: true)

@discardableResult
@MainActor func install(_ data: Data, at url: URL) throws -> Bool {
    if files.fileExists(atPath: url.path), try Data(contentsOf: url) == data { return false }
    try files.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: url, options: .atomic)
    return true
}

// SIGUSR1 is Helix's config reload. A process still starting has no handler yet.
@MainActor func reloadEditors() {
    var mib = [CTL_KERN, KERN_PROC, KERN_PROC_UID, Int32(getuid())]
    var size = 0
    guard sysctl(&mib, 4, nil, &size, nil, 0) == 0 else { return }
    let stride = MemoryLayout<kinfo_proc>.stride
    var processes = [kinfo_proc](repeating: kinfo_proc(), count: size / stride + 32)
    size = processes.count * stride
    let result = processes.withUnsafeMutableBytes { sysctl(&mib, 4, $0.baseAddress, &size, nil, 0) }
    guard result == 0 else { return }
    for var entry in processes.prefix(size / stride) {
        guard entry.kp_proc.p_sigcatch & (1 << (SIGUSR1 - 1)) != 0 else { continue }
        let isHelix = withUnsafeBytes(of: &entry.kp_proc.p_comm) { bytes in
            bytes.starts(with: "hx\0".utf8)
        }
        if isHelix { kill(entry.kp_proc.p_pid, SIGUSR1) }
    }
}

@MainActor func apply(_ mode: String) throws {
    let starship = config.appendingPathComponent("starship.toml")
    let base = files.fileExists(atPath: starship.path) ? starship : source.appendingPathComponent("starship.toml")
    let toml = try String(contentsOf: base, encoding: .utf8)
    let selected = toml.replacingOccurrences(of: #"(?m)^palette = "signal_(?:light|dark)"$"#,
        with: "palette = \"signal_\(mode)\"", options: .regularExpression)
    let palette = Data(selected.utf8)
    try install(palette, at: starship)

    // Older zsh sessions can still point STARSHIP_CONFIG at this generated copy.
    let env = ProcessInfo.processInfo.environment
    let home = files.homeDirectoryForCurrentUser
    let userConfig = URL(fileURLWithPath: env["XDG_CONFIG_HOME"] ?? home.appendingPathComponent(".config").path)
    let cache = URL(fileURLWithPath: env["XDG_CACHE_HOME"] ?? home.appendingPathComponent(".cache").path)
    let legacy = cache.appendingPathComponent("starship/glacier-light.toml")
    if config.standardizedFileURL.path == userConfig.standardizedFileURL.path,
       (try? legacy.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true,
       (try? Data(contentsOf: legacy)) == Data(toml.utf8) {
        try install(palette, at: legacy)
    }

    let skin = try Data(contentsOf: source.appendingPathComponent("k9s/skins/signal-\(mode).yaml"))
    try install(skin, at: k9s.appendingPathComponent("skins/signal.yaml"))

    let theme = try Data(contentsOf: source.appendingPathComponent("helix/themes/signal-\(mode).toml"))
    if try install(theme, at: config.appendingPathComponent("helix/themes/signal.toml")), ["watch", "system"].contains(args[0]) {
        reloadEditors()
    }

    if config.standardizedFileURL.path == userConfig.standardizedFileURL.path {
        let codex = Process()
        codex.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        codex.arguments = [source.deletingLastPathComponent().appendingPathComponent("scripts/set-codex-appearance").path, mode]
        try codex.run()
        codex.waitUntilExit()
        if codex.terminationStatus != 0 { NSLog("Could not save Codex CLI appearance") }
    }
}

@MainActor func systemMode() -> String {
    UserDefaults.standard.synchronize()
    return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark" ? "dark" : "light"
}

@MainActor func syncSystem() {
    do { try apply(systemMode()) }
    catch { NSLog("Terminal appearance update failed: %@", error.localizedDescription); exit(1) }
}

@MainActor final class AppearanceObserver: NSObject {
    @objc func appearanceChanged(_ notification: Notification) { syncSystem() }
}

if args[0] == "watch" {
    let center = DistributedNotificationCenter.default()
    let observer = AppearanceObserver()
    center.addObserver(observer, selector: #selector(AppearanceObserver.appearanceChanged(_:)),
                       name: .init("AppleInterfaceThemeChangedNotification"), object: nil,
                       suspensionBehavior: .deliverImmediately)
    syncSystem()
    withExtendedLifetime(observer) { RunLoop.main.run() }
} else {
    try apply(args[0] == "system" ? systemMode() : args[0])
}
