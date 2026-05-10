import SwiftUI

// MARK: - Status & Controls View
// New tab for Control Center and Status Bar tweaks on iOS 26.2b1

struct StatusAndControlsView: View {
    @ObservedObject var featureFlagsStore: FeatureFlagsStore
    @ObservedObject var toolStore: ToolStore
    @State private var isApplying = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Status Bar")) {
                    Toggle("Hide Carrier Name", isOn: $featureFlagsStore.hideCarrierName)
                    TextField("Custom Carrier Text", text: $featureFlagsStore.customCarrierText)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section(header: Text("Display")) {
                    Toggle("Always-On Display Override", isOn: $featureFlagsStore.aodOverride)
                    Toggle("Force Stage Manager (iPhone)", isOn: $featureFlagsStore.forceStageManager)
                    Toggle("External Display Support", isOn: $featureFlagsStore.externalDisplaySupport)
                }
                
                Section {
                    Button(action: applyTweaks) {
                        if isApplying {
                            ProgressView()
                        } else {
                            Label("Apply Status Tweaks", systemImage: "checkmark.circle.fill")
                        }
                    }
                    .disabled(isApplying)
                }
            }
            .navigationTitle("Status & Controls")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func applyTweaks() {
        isApplying = true
        // TODO: Call SparseRestore / patch engine with MobileGestalt keys
        Task {
            // Simulate patch for now
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            isApplying = false
            // In full version, this would trigger toolRunner or featureFlagsStore.apply()
        }
    }
}

// MARK: - Extension for FeatureFlagsStore (we'll extend later)
extension FeatureFlagsStore {
    @Published var hideCarrierName: Bool = false
    @Published var customCarrierText: String = ""
    @Published var aodOverride: Bool = false
    @Published var forceStageManager: Bool = false
    @Published var externalDisplaySupport: Bool = false
}
