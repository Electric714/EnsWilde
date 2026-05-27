import Foundation
import SwiftUI

// MARK: - JSONPatchModule
// Dynamic patch loaded from JSON (e.g. patch-template.json, status-controls.json)
struct JSONPatchModule: PatchModule, Codable {
    let id: String
    let title: String
    let description: String
    let defaultEnabled: Bool
    let requiresRespring: Bool
    
    // Optional extra fields from JSON
    let category: String?
    let ios_version: String?
    
    func apply() async throws {
        print("[JSONPatchModule] Applying JSON-driven patch: \(title)")
        // In real implementation: parse PatchDefinition and apply via SparseRestore or toolRunner
        // For now: log success (extend with actual logic from ToolRunner)
        try await Task.sleep(nanoseconds: 500_000_000) // Simulate work
    }
}

// Codable support for loading from patch JSON files
struct PatchDefinition: Codable {
    let id: String
    let title: String
    let description: String
    let toggles: [ToggleDefinition]?
}

struct ToggleDefinition: Codable {
    let key: String
    let title: String
    let type: String
}