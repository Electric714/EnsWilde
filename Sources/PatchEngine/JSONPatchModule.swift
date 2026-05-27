import Foundation
import SwiftUI

/// A JSON-based patch module loaded from bundle
struct JSONPatchModule: Codable, PatchModule {
    let id: String
    let title: String
    let description: String
    let category: String
    let defaultEnabled: Bool
    let requiresRespring: Bool
    let iOSVersionMin: String?
    let patchDefinitions: [PatchDefinition]
    
    var hasCustomUI: Bool { false }
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, category, defaultEnabled, requiresRespring, iOSVersionMin, patchDefinitions
    }
    
    func apply() async throws {
        print("[JSONPatchModule] Applying patch: \(title)")
        for def in patchDefinitions {
            PatchModuleHelper.applyPatch(def)
        }
    }
    
    @MainActor
    func makeCustomView(binding: Binding<Bool>) -> AnyView {
        AnyView(EmptyView())
    }
}

// Codable support for PatchDefinition
extension PatchDefinition: Codable {
    enum CodingKeys: String, CodingKey {
        case operation, targetType, key, value, targetPath
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        operation = try container.decode(String.self, forKey: .operation)
        targetType = try container.decode(String.self, forKey: .targetType)
        key = try container.decode(String.self, forKey: .key)
        targetPath = try container.decodeIfPresent(String.self, forKey: .targetPath)
        
        if let valueDict = try container.decodeIfPresent([String: String?].self, forKey: .value) {
            let valueStr = valueDict["value"] as? String?
            let typeStr = valueDict["type"] as? String?
            value = (value: valueStr ?? nil, type: typeStr ?? nil)
        } else {
            value = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(operation, forKey: .operation)
        try container.encode(targetType, forKey: .targetType)
        try container.encode(key, forKey: .key)
        try container.encodeIfPresent(targetPath, forKey: .targetPath)
        
        if let value = value {
            try container.encode(["value": value.value, "type": value.type], forKey: .value)
        }
    }
}
