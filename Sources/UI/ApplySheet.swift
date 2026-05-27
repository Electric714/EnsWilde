import SwiftUI

// MARK: - Apply Sheet (Feather-style)
// Extracted from ContentView.swift for better maintainability
struct ApplySheet: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Binding var logs: [String]
    @Binding var isRunning: Bool
    @Binding var progressText: String
    @Binding var enableRespring: Bool
    @Binding var bookassetdUUID: String
    var onApply: () -> Void
    var onClearUUID: () -> Void
    var onClose: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                optionsSection
                statusSection
                if !logs.isEmpty {
                    logsSection
                }
                actionsSection
            }
            .headerProminence(.increased)
            .navigationTitle(L("apply_tweaks"))
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

    @ViewBuilder
    private var optionsSection: some View {
        Section {
            Toggle(L("respring_after_apply"), isOn: $enableRespring)
        }
    }

    @ViewBuilder
    private var statusSection: some View {
        Section(header: Text(L("section_status"))) {
            HStack(spacing: 12) {
                if isRunning {
                    ProgressView()
                }
                Text(progressText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var logsSection: some View {
        Section(header: Text(L("logs"))) {
            ForEach(logs, id: \.self) { log in
                Text(log)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var actionsSection: some View {
        Section(header: Text(L("section_actions"))) {
            Button(L("clear_uuid"), role: .destructive) {
                onClearUUID()
            }
            .disabled(bookassetdUUID.isEmpty)
        }

        Section {
            WalletStyleButton(
                title: isRunning ? L("applying") : L("apply_enabled_tweaks"),
                isLoading: isRunning,
                disabled: isRunning,
                action: onApply
            )
        }
    }
}
