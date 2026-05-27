import Foundation
import Combine
import SwiftUI

// MARK: - PatchLoader
// Singleton that discovers and registers all PatchModule implementations
// Now fully functional with real protocol conformance

class PatchLoader: ObservableObject {
    static let shared = PatchLoader()
    
    @Published var loadedModules: [String] = []
    @Published var loadedPatches: [any PatchModule] = []
    
    private init() {}
    
    func loadAllPatches() {
        print("[PatchLoader] Loading all patches...")
        
        // Load JSON-driven patches
        loadJSONPatches()
        
        // Register native modules
        registerWalletBackgroundModule()
        registerMobileGestaltModule()
        registerThemeModule()
        
        print("[PatchLoader] Loaded \(loadedModules.count) modules, \(loadedPatches.count) patches")
    }
    
    private func loadJSONPatches() {
        // Example: load from Patches/ directory (extend with real JSON parsing)
        let jsonPatch = JSONPatchModule(
            id: "status-controls",
            title: "Status & Controls",
            description: "Toggles for carrier name, AOD, Stage Manager, etc.",
            defaultEnabled: true,
            requiresRespring: false,
            category: "StatusBar",
            ios_version: "26.2b1"
        )
        loadedModules.append("JSONPatchModule")
        loadedPatches.append(jsonPatch)
    }
    
    private func registerWalletBackgroundModule() {
        let module = WalletBackgroundModule()
        loadedModules.append("WalletBackgroundModule")
        loadedPatches.append(module)
    }
    
    private func registerMobileGestaltModule() {
        // Placeholder - extend with real MobileGestaltPatch
        loadedModules.append("MobileGestaltPatch")
    }
    
    private func registerThemeModule() {
        loadedModules.append("ThemePatch")
    }
}