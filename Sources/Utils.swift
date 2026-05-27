import Foundation
import UIKit

struct Utils {
    static var bgTask: UIBackgroundTaskIdentifier = .invalid
    static var udid: String = ""
    static var port: Int = 0
    static let os = ProcessInfo.processInfo.operatingSystemVersion

    static func isIOSVersionSupported() -> Bool {
        let v = os
        if v.majorVersion < 18 { return false }
        if v.majorVersion > 26 { return false }
        if v.majorVersion == 26 && v.minorVersion > 2 { return false }
        return true
    }

    static func getIOSVersionString() -> String {
        let v = os
        return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
    }

    static func requiresVersion(_ major: Int) -> Bool {
        return os.majorVersion >= major
    }

    static func reservePort() throws -> Int {
        for p in 49152...65535 {
            if isPortAvailable(p) { return p }
        }
        throw NSError(domain: "Utils", code: -1, userInfo: [NSLocalizedDescriptionKey: "No free port found"])
    }

    private static func isPortAvailable(_ port: Int) -> Bool {
        var addr = sockaddr_in()
        addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t(port).bigEndian
        addr.sin_addr.s_addr = INADDR_ANY.bigEndian

        let sock = socket(AF_INET, SOCK_STREAM, 0)
        guard sock >= 0 else { return false }
        defer { close(sock) }

        let result = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
                bind(sock, sockaddrPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        return result == 0
    }

    // New methods to fix build
    static func ensureHTTPServerReady(timeoutSeconds: Int = 5) async throws {
        let start = Date()
        let url = URL(string: "http://127.0.0.1:\(port)/ping")!
        while Date().timeIntervalSince(start) < Double(timeoutSeconds) {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    return
                }
            } catch {}
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2s
        }
        throw NSError(domain: "Utils", code: -1, userInfo: [NSLocalizedDescriptionKey: "HTTP server did not become ready within timeout"])
    }

    static func verifyLocalHTTPFileAccessible(pathComponent: String) async throws {
        let url = URL(string: "http://127.0.0.1:\(port)/\(pathComponent)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Utils", code: -1, userInfo: [NSLocalizedDescriptionKey: "File not accessible: \(pathComponent)"])
        }
    }
}
