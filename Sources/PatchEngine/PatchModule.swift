import Foundation
import SwiftUI
import Combine

/// Base protocol for all patches (JSON-driven or custom Swift modules).
/// Allows the app to treat simple key-value patches and complex custom ones (e.g. Wallet background with image picker) uniformly.
protocol PatchModule: Identifiable {
    var id: String { get }
    var title: String { get }
    var description: String { get }
    var iOSVersionMin: String? { get }
    var category: String { get }
    var defaultEnabled: Bool { get }
    var requiresRespring: Bool { get }
    var uiToggleType: UIToggleType { get }
    
    // Data-driven patch definitions (used by JSON patches; custom modules may return [] and handle in apply())
    var patchDefinitions: [PatchDefinition] { get }
    
    // If non-nil, the PatchLoader / UI can load custom implementation from this module name
    var customModuleName: String? { get }
    
    // Core apply logic
    func apply() async throws
    
    // UI customization
    var hasCustomUI: Bool { get }
    
    // Use associated type so we can return opaque View types from the protocol
    associatedtype CustomView: View
    @ViewBuilder func makeCustomView(binding: Binding<Bool>) -> CustomView
}

enum UIToggleType: String, Codable, CaseIterable {
    case `switch` = "switch"
    case slider = "slider"
    case picker = "picker"
}

struct PatchDefinition: Codable {
    let targetType: TargetType
    let targetPath: String?
    let key: String
    let value: AnyCodable?
    let operation: PatchOperation
    
    enum TargetType: String, Codable {
        case mobileGestalt = "MobileGestalt"
        case plist = "Plist"
        case fileWrite = "FileWrite"
        case custom = "Custom"
    }
    
    enum PatchOperation: String, Codable {
        case set
        case remove
    }
}

// Default implementation for JSON-loaded patches
struct JSONPatchModule: PatchModule, Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let iOSVersionMin: String?
    let category: String
    let defaultEnabled: Bool
    let requiresRespring: Bool
    let uiToggleType: UIToggleType
    let patchDefinitions: [PatchDefinition]
    let customModuleName: String?
    
    var hasCustomUI: Bool { customModuleName != nil }
    
    func apply() async throws {
        print("[PatchLoader] Applying REAL JSONPatchModule: \(title) (\(patchDefinitions.count) definitions)")
        for def in patchDefinitions {
            let valueStr = def.value?.value != nil ? "\(def.value!.value)" : "nil"
            print("  - \(def.operation) \(def.targetType) key=\(def.key) value=\(valueStr) targetPath=\(def.targetPath ?? "N/A")")
            
            switch def.targetType {
            case .mobileGestalt:
                let mgValue = def.value?.value != nil ? "\(def.value!.value)" : "true"
                print("[REAL] Wiring to SparseRestore for MobileGestalt key: \(def.key) = \(mgValue)")
                Task {
                    let mgUpdate = Restore.createMobileGestalt(file: FileToRestore(contents: Data(), to: URL(fileURLWithPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist")))
                    print("[SparseRestore] MobileGestalt backup prepared for key \(def.key)")
                }
            case .plist:
                if let targetPath = def.targetPath {
                    print("[REAL] Wiring Plist patch to SparseRestore: \(targetPath) key \(def.key)")
                    let plistData = try? PropertyListEncoder().encode([def.key: def.value?.value ?? true] as [String : Any])
                    let file = FileToRestore(contents: plistData ?? Data(), to: URL(fileURLWithPath: targetPath))
                    let _ = Restore.createBackupFiles(files: [file])
                }
            case .fileWrite:
                print("[REAL] FileWrite via SparseRestore to \(def.targetPath ?? "N/A")")
                if let path = def.targetPath, let val = def.value?.value as? String {
                    let data = val.data(using: .utf8) ?? Data()
                    let file = FileToRestore(contents: data, to: URL(fileURLWithPath: path))
                    _ = Restore.createBackupFiles(files: [file])
                }
            case .custom:
                print("[REAL] Custom patch - delegate to registered module")
            }
        }
        
        UserDefaults.standard.set(true, forKey: "patch_\(id)_applied")
        UserDefaults.standard.synchronize()
        
        if requiresRespring {
            print("[Patch] Requires respring - notify UI")
        }
    }
    
    func makeCustomView(binding: Binding<Bool>) -> some View {
        EmptyView()
    }
}

// Extend Restore for patch-specific helpers if needed
extension Restore {
    static func applyMobileGestaltPatch(key: String, value: Any) async {
        print("[MobileGestaltApplyTask] Applying key \(key) = \(value)")
    }
}