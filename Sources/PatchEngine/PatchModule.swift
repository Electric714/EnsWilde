import Foundation
import SwiftUI

// MARK: - PatchModule Protocol
// Core protocol for all dynamic patch modules in EnsWilde
// Supports JSON-driven and native Swift patches

protocol PatchModule {
    var id: String { get }
    var title: String { get }
    var description: String { get }
    var defaultEnabled: Bool { get }
    var requiresRespring: Bool { get }
    
    func apply() async throws
}

// Optional: Enum for toggle types if needed by UI
enum UIToggleType {
    case bool
    case string
    case number
}

// MARK: - PatchItem (for backward compatibility with PatchLoader)
struct PatchItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let defaultEnabled: Bool
    let requiresRespring: Bool
    
    func apply() async throws {
        print("[PatchItem] Applying legacy patch: \(title)")
        // TODO: Route to actual module if needed
    }
}