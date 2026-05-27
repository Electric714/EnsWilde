import Foundation
import UIKit

struct Utils {
    static var bgTask: UIBackgroundTaskIdentifier = .invalid
    static var udid: String = ""
    static var port: Int = 0
    
    static var os: OperatingSystemVersion {
        return ProcessInfo.processInfo.operatingSystemVersion
    }
    
    static func isIOSVersionSupported() -> Bool {
        let v = os
        // Support iOS 18.0 to 26.2 (current beta)
        return (v.majorVersion >= 18 && v.majorVersion <= 26)
    }
    
    static func getIOSVersionString() -> String {
        let v = os
        return "\(v.majorVersion).\(v.minorVersion)"
    }
    
    static func reservePort() -> Int {
        // Reserve a high port for local server
        return Int.random(in: 49152...65535)
    }
}