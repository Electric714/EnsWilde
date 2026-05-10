// PatchLoader.swift
// Core plugin loader for EnsWilde Plugin System

import Foundation

class PatchLoader {
    static let shared = PatchLoader()
    
    private(set) var loadedPatches: [any PatchModule] = []
    
    func loadAllPatches() {
        // Scan Patches/ directory for .json files
        // Parse JSON and create PatchModule instances
        // Register them dynamically
        print("PatchLoader: Loading all plugins...")
        // TODO: Implement full scanning logic
        loadedPatches = []
    }
}