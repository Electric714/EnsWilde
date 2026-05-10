import Foundation
import SwiftUI

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
    @ViewBuilder func makeCustomView(binding: Binding<Bool>) -> some View
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
        print("[PatchLoader] Applying JSONPatchModule: \(title) (\(patchDefinitions.count) definitions)")
        for def in patchDefinitions {
            print("  - \(def.operation) \(def.targetType) key=\(def.key) value=\(def.value?.value ?? "nil") targetPath=\(def.targetPath ?? "N/A")")
        }
        // POC wiring: simulate apply success (in real impl, delegate to SparseRestore/BookRestoreApplyTask based on targetType)
        // For MobileGestalt: would load/modify MG plist and push via AFC + itunesstored restart (see MobileGestaltApplyTask)
        // For Plist: edit plist and push
        // For now, mark as applied in UserDefaults for demo
        UserDefaults.standard.set(true, forKey: "patch_\(id)_applied")
        UserDefaults.standard.synchronize()
    }
    
    @ViewBuilder func makeCustomView(binding: Binding<Bool>) -> some View {
        // Generic toggle UI will be provided by main app's dynamic list
        // Custom modules override this to provide e.g. image picker for Wallet
        EmptyView()
    }
}
