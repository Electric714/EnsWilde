import Foundation
import Combine
import SwiftUI

/// Scans Patches/ (and future Community/) for JSON patch definitions.
/// Auto-registers them as loadable toggles in the UI and apply system.
/// Also supports registering custom Swift modules that conform to PatchModule.
final class PatchLoader: ObservableObject {
    @Published var loadedPatches: [any PatchModule] = []
    
    static let shared = PatchLoader()
    
    private init() {}
    
    /// Call on app launch (e.g. in MyApp.swift or ContentView onAppear)
    func loadAllPatches() {
        var allPatches: [any PatchModule] = []
        
        // 1. Load JSON patches from bundle (Patches/ and subdirs)
        if let patchesDir = Bundle.main.url(forResource: "Patches", withExtension: nil) {
            allPatches += loadJSONFromDirectory(patchesDir)
        }
        
        // TODO: Future support for user-added in Documents/Patches/Community/
        // Requires adding Files app support or explicit import. For v1, bundled only.
        
        // 2. TODO: Register any built-in custom Swift modules here
        // e.g. allPatches.append(WalletBackgroundModule())
        
        self.loadedPatches = allPatches
        print("[PatchLoader] Loaded \(allPatches.count) patches/modules on launch.")
    }
    
    private func loadJSONFromDirectory(_ dir: URL) -> [JSONPatchModule] {
        var results: [JSONPatchModule] = []
        let fm = FileManager.default
        
        guard let enumerator = fm.enumerator(at: dir, includingPropertiesForKeys: [.isRegularFileKey, .nameKey]) else {
            return []
        }
        
        for case let url as URL in enumerator {
            guard url.pathExtension.lowercased() == "json" else { continue }
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let patch = try decoder.decode(JSONPatchModule.self, from: data)
                results.append(patch)
            } catch {
                print("[PatchLoader] Failed to decode \(url.lastPathComponent): \(error)")
            }
        }
        return results
    }
    
    /// For custom Swift modules (advanced patches)
    func register(_ module: any PatchModule) {
        if !loadedPatches.contains(where: { $0.id == module.id }) {
            loadedPatches.append(module)
        }
    }
}
