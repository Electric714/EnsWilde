import SwiftUI

// MARK: - Patch Module Protocol
protocol PatchModule: Identifiable, ObservableObject {
    var id: String { get }
    var title: String { get }
    var description: String { get }
    var category: String { get }
    var isEnabled: Bool { get set }
    var requiresBackup: Bool { get }
    
    func applyPatch(using engine: SparseRestoreEngine) async throws
    func isCompatible(with iOSVersion: String) -> Bool
}

// Default implementation
extension PatchModule {
    var requiresBackup: Bool { true }
    
    func isCompatible(with iOSVersion: String) -> Bool {
        return true // Can be overridden per patch
    }
}