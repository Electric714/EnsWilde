import Foundation
import Combine
import SwiftUI

// ================================================
// PatchLoader - Singleton for loading all exploit patches
// Fixed by Grok 2026-05-27
// ================================================

class PatchLoader: ObservableObject {
    static let shared = PatchLoader()
    
    @Published var loadedModules: [String] = []
    
    private init() {}
    
    func loadAllPatches() {
        print("[PatchLoader] Loading all patches...")
        
        // Load JSON-based patches
        loadJSONPatches()
        
        // Register known modules
        registerWalletBackgroundModule()
        registerOtherModules()
        
        print("[PatchLoader] Loaded \(loadedModules.count) modules")
    }
    
    private func loadJSONPatches() {
        // Placeholder for JSON patch loading from PatchModules/
        // In real impl: scan PatchModules/*.json and apply
        loadedModules.append("JSONPatchModule")
    }
    
    private func registerWalletBackgroundModule() {
        // WalletBackgroundModule from PatchModules/
        loadedModules.append("WalletBackgroundModule")
    }
    
    private func registerOtherModules() {
        // Add more as needed (MobileGestalt, Themes, etc.)
        loadedModules.append("MobileGestaltPatch")
        loadedModules.append("ThemePatch")
    }
}