import SwiftUI

// MARK: - Status Sheet (Feather-style)
// Extracted from ContentView.swift for better maintainability
struct StatusSheet: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Binding var pairingFileLoaded: Bool
    @Binding var heartbeatRunning: Bool
    @Binding var ddiMounted: Bool
    var onImportPairing: () -> Void
    var onResetPairing: () -> Void
    var onMountDDI: () -> Void
    var onClose: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(L("system_status"))) {
                    CardRow(title: L("status_pairing_file"), subtitle: pairingFileLoaded ? L("status_pairing_loaded") : L("status_pairing_missing"), ok: pairingFileLoaded, showChevron: false, trailing: nil)

                    CardRow(title: L("status_heartbeat"), subtitle: heartbeatRunning ? L("status_heartbeat_running") : L("status_heartbeat_stopped"), ok: heartbeatRunning, showChevron: false, trailing: nil)

                    CardRow(title: L("status_ddi"), subtitle: ddiMounted ? L("status_ddi_mounted") : L("status_ddi_unmounted"), ok: ddiMounted, showChevron: false, trailing: nil)
                }

                Section(header: Text(L("section_actions"))) {
                    if heartbeatRunning && !ddiMounted {
                        Button(L("button_mount_ddi")) {
                            onMountDDI()
                        }
                    }
                    
                    Button(pairingFileLoaded ? L("button_reset_pairing") : L("button_select_pairing")) {
                        if pairingFileLoaded { onResetPairing() } else { onImportPairing() }
                        onClose()
                    }
                    .tint(pairingFileLoaded ? .red : .accentColor)
                }
            }
            .headerProminence(.increased)
            .navigationTitle(L("system_status"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
