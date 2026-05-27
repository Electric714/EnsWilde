import SwiftUI
import UniformTypeIdentifiers
import UIKit
import Network

// MARK: - ToolRunState
enum ToolRunState {
    case idle
    case running(String)
    case success
    case failed(String)
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @AppStorage("PairingFile") private var pairingFile: String?
    
    @State private var heartbeatRunning = false
    @State private var ddiMounted = false
    @State private var showPairingFileImporter = false
    @State private var showErrorAlert = false
    @State private var lastError: String?
    @State private var showStatusSheet = false
    @State private var _showApplySheet = false
    @State private var path = NavigationPath()
    @State private var showUUIDAlert = false
    @State private var showPairingReplaceConfirm = false
    @State private var pendingPairingFileText: String?
    
    var showApplySheetBinding: Binding<Bool>? = nil
    var showStatusSheetBinding: Binding<Bool>? = nil
    var hideBottomApplyButton: Bool = false
    var isInNestedViewBinding: Binding<Bool>? = nil
    var isSystemReadyBinding: Binding<Bool>? = nil
    var heartbeatRunningBinding: Binding<Bool>? = nil
    var ddiMountedBinding: Binding<Bool>? = nil
    
    @State private var _isInNestedView = false
    @State private var _isSystemReadyState = false
    
    private var isInNestedView: Binding<Bool> { isInNestedViewBinding ?? $_isInNestedView }
    private var isSystemReady: Binding<Bool> { isSystemReadyBinding ?? $_isSystemReadyState }
    private var showApplySheet: Binding<Bool> { showApplySheetBinding ?? $_showApplySheet }
    private var statusSheet: Binding<Bool> { showStatusSheetBinding ?? $showStatusSheet }
    private var _isSystemReady: Bool { pairingFile != nil && heartbeatRunning && ddiMounted }
    
    @ObservedObject var toolStore: ToolStore
    @ObservedObject var toolRunner: ToolRunner
    @ObservedObject var walletStore: AppleWalletStore
    @ObservedObject var themeStore: PasscodeThemeStore
    @ObservedObject var featureFlagsStore: FeatureFlagsStore
    
    private let versionJSONURL = URL(string: "https://raw.githubusercontent.com/Electric714/EnsWilde/refs/heads/main/version.json")!
    @State private var showUpdateAlert = false
    @State private var updateURL: URL?
    @State private var updateMessage: String = ""
    @State private var lastCheckedBuild: Int = -1
    @AppStorage("IgnoredUpdateBuild") private var ignoredUpdateBuild: Int = 0
    @State private var pendingRemoteBuild: Int = 0
    
    @ObservedObject private var viewModel = ContentViewModel()
    
    init(
        themeStore: PasscodeThemeStore,
        toolStore: ToolStore,
        toolRunner: ToolRunner,
        walletStore: AppleWalletStore,
        featureFlagsStore: FeatureFlagsStore,
        showApplySheetBinding: Binding<Bool>? = nil,
        showStatusSheetBinding: Binding<Bool>? = nil,
        hideBottomApplyButton: Bool = false,
        isInNestedViewBinding: Binding<Bool>? = nil,
        isSystemReadyBinding: Binding<Bool>? = nil,
        heartbeatRunningBinding: Binding<Bool>? = nil,
        ddiMountedBinding: Binding<Bool>? = nil
    ) {
        self.themeStore = themeStore
        self.toolStore = toolStore
        self.toolRunner = toolRunner
        self.walletStore = walletStore
        self.featureFlagsStore = featureFlagsStore
        self.showApplySheetBinding = showApplySheetBinding
        self.showStatusSheetBinding = showStatusSheetBinding
        self.hideBottomApplyButton = hideBottomApplyButton
        self.isInNestedViewBinding = isInNestedViewBinding
        self.isSystemReadyBinding = isSystemReadyBinding
        self.heartbeatRunningBinding = heartbeatRunningBinding
        self.ddiMountedBinding = ddiMountedBinding
    }

    var body: some View {
        NavigationStack(path: $path) {
            Form {
                statusSection
                tweaksSection
            }
            .headerProminence(.increased)
            .navigationTitle("EnsWilde")
            .navigationDestination(for: String.self) { route in
                destinationView(for: route)
            }
        }
        .onChange(of: path) { newPath in
            isInNestedView.wrappedValue = !newPath.isEmpty
        }
        .onChange(of: _isSystemReady) { newValue in
            isSystemReady.wrappedValue = newValue
        }
        .onChange(of: heartbeatRunning) { newValue in
            heartbeatRunningBinding?.wrappedValue = newValue
        }
        .onChange(of: ddiMounted) { newValue in
            ddiMountedBinding?.wrappedValue = newValue
        }
        .onAppear {
            isSystemReady.wrappedValue = _isSystemReady
            heartbeatRunningBinding?.wrappedValue = heartbeatRunning
            ddiMountedBinding?.wrappedValue = ddiMounted
            viewModel.updatePairingFile(pairingFile)
            runStartupChecksOnce()
            checkForUpdate()
            refreshSystemStatus()
            startNetworkMonitoring()
        }
        .sheet(isPresented: statusSheet) {
            StatusSheet(
                pairingFileLoaded: .constant(pairingFile != nil),
                heartbeatRunning: $heartbeatRunning,
                ddiMounted: $ddiMounted,
                onImportPairing: { showPairingFileImporter = true },
                onResetPairing: { resetPairing() },
                onMountDDI: { viewModel.attemptAutoMountDDI() },
                onClose: { statusSheet.wrappedValue = false }
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: showApplySheet) {
            ApplySheet(
                logs: .constant(toolRunner.logs.map { $0.text }),
                isRunning: .constant(isApplyRunning(toolRunner.state)),
                progressText: .constant(applyStatusText(toolRunner.state)),
                enableRespring: $toolStore.soundRespringEnabled,
                bookassetdUUID: .constant(toolStore.bookassetdUUID ?? ""),
                onApply: {
                    Task {
                        if toolStore.bookassetdUUID == nil || toolStore.bookassetdUUID?.isEmpty == true {
                            showUUIDAlert = true
                            return
                        }
                        await toolRunner.applyAll(isSystemReady: _isSystemReady, store: toolStore, walletStore: walletStore, themeStore: themeStore, featureFlagsStore: featureFlagsStore)
                        if case .success = toolRunner.state {
                            try? await Task.sleep(nanoseconds: 8_000_000_000)
                            if toolStore.soundRespringEnabled {
                                try? respringNow()
                            } else {
                                if let bundleID = Bundle.main.bundleIdentifier {
                                    LSApplicationWorkspaceDefaultWorkspace().openApplication(withBundleID: bundleID)
                                }
                            }
                        }
                        if case .failed(let message) = toolRunner.state {
                            lastError = message
                            showErrorAlert = true
                        }
                    }
                },
                onClearUUID: { toolStore.bookassetdUUID = nil },
                onClose: { showApplySheet.wrappedValue = false }
            )
            .presentationDetents([.large])
        }
        .fileImporter(
            isPresented: $showPairingFileImporter,
            allowedContentTypes: [.propertyList, UTType(filenameExtension: "mobiledevicepairing", conformingTo: .data)!],
            onCompletion: handleFileImport
        )
        .alert("System Message", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(lastError ?? "An unknown error occurred.")
        }
        .alert("Update Available", isPresented: $showUpdateAlert) {
            Button("Cancel", role: .cancel) { ignoredUpdateBuild = pendingRemoteBuild }
            Button("Open") { if let url = updateURL { UIApplication.shared.open(url) } }
        } message: {
            Text(updateMessage)
        }
        .alert("UUID Required", isPresented: $showUUIDAlert) {
            Button("Cancel", role: .cancel) { }
            Button("OK") { handleUUIDCapture() }
        } message: {
            Text("Please open Books app and download a book to capture UUID.")
        }
        .alert("Replace Existing Pairing File?", isPresented: $showPairingReplaceConfirm) {
            Button("Cancel", role: .cancel) { pendingPairingFileText = nil }
            Button("Replace", role: .destructive) {
                if let text = pendingPairingFileText { importPairingFile(text) }
                pendingPairingFileText = nil
            }
        } message: {
            Text("You already have a pairing file loaded. Do you want to replace it?")
        }
        .onChange(of: scenePhase) { handleScenePhase($0) }
        .onDisappear {
            stopNetworkMonitoring()
            viewModel.stopDDIMonitoring()
            viewModel.cancelPairingResetTimer()
        }
    }

    // MARK: - Body Sections
    @ViewBuilder private var statusSection: some View {
        Section(header: Text(L("section_status"))) {
            CardRow(title: L("system_status"), subtitle: _isSystemReady ? L("system_status_ready") : L("system_status_not_ready"), ok: _isSystemReady, showChevron: false, trailing: nil)
            if pairingFile == nil {
                Button(action: { showPairingFileImporter = true }) {
                    Label { VStack(alignment: .leading) { Text(L("pairing_file_missing")); Text(L("pairing_file_import_prompt")).font(.caption) } } icon: { Image(systemName: "exclamationmark.triangle.fill") }
                }
            }
            if !heartbeatRunning && pairingFile != nil {
                Label { VStack(alignment: .leading) { Text(L("heartbeat_not_running")); Text(L("heartbeat_enable_vpn")).font(.caption) } } icon: { Image(systemName: "exclamationmark.triangle.fill") }
            }
            if !ddiMounted && pairingFile != nil && heartbeatRunning {
                ddiStatusLabel
            }
        }
    }

    @ViewBuilder private var ddiStatusLabel: some View {
        Label { VStack(alignment: .leading) { Text(L("ddi_not_mounted")) } } icon: { Image(systemName: "info.circle.fill") }
    }

    @ViewBuilder private var tweaksSection: some View {
        Section(header: Text(L("section_tweaks"))) {
            toolNavigationLink(value: "MobileGestalt", title: L("tool_mobile_gestalt"), subtitle: L("tool_mobile_gestalt_desc"), icon: "cpu", isEnabled: toolStore.replaceMobileGestaltEnabled)
            toolNavigationLink(value: "ThemesUI", title: L("tool_themes_ui"), subtitle: L("tool_themes_ui_desc"), icon: "paintbrush", isEnabled: toolStore.themesUIEnabled)
            toolNavigationLink(value: "PasscodeTheme", title: L("tool_passcode_theme"), subtitle: L("tool_passcode_theme_desc"), icon: "lock.rectangle", isEnabled: themeStore.passcodeThemeEnabled)
            toolNavigationLink(value: "DisableSound", title: L("tool_disable_sound"), subtitle: L("tool_disable_sound_desc"), icon: "speaker.slash", isEnabled: toolStore.disableSoundEnabled)
            toolNavigationLink(value: "AppleWallet", title: L("tool_apple_wallet"), subtitle: L("tool_apple_wallet_desc"), icon: "wallet.pass", isEnabled: walletStore.appleWalletEnabled)
            toolNavigationLink(value: "FeatureFlags", title: L("tool_feature_flags"), subtitle: L("tool_feature_flags_desc"), icon: "flag", isEnabled: featureFlagsStore.featureFlagsEnabled)
            toolNavigationLink(value: "zPatchCustom", title: L("tool_zpatch_custom"), subtitle: L("tool_zpatch_custom_desc"), icon: "wrench.and.screwdriver", isEnabled: toolStore.zPatchCustomEnabled)
        }
    }

    @ViewBuilder private func toolNavigationLink(value: String, title: String, subtitle: String, icon: String, isEnabled: Bool) -> some View {
        NavigationLink(value: value) {
            HStack {
                Label { VStack(alignment: .leading, spacing: 2) { Text(title); Text(subtitle).font(.caption).foregroundStyle(.secondary) } } icon: { Image(systemName: icon) }
                Spacer()
                if isEnabled { Image(systemName: "checkmark.seal.fill").foregroundStyle(.green).font(.caption) }
            }
        }
    }

    @ViewBuilder private func destinationView(for route: String) -> some View {
        if route == "DisableSound" { DisableSoundView() }
        else if route == "MobileGestalt" { MobileGestaltView(toolStore: toolStore) }
        else if route == "AppleWallet" { AppleWalletView(walletStore: walletStore) }
        else if route == "PasscodeTheme" { PasscodeThemeView(themeStore: themeStore) }
        else if route == "ThemesUI" { ThemesUIView(toolStore: toolStore) }
        else if route == "zPatchCustom" { zPatchCustomView() }
        else if route == "FeatureFlags" { FeatureFlagsView(store: featureFlagsStore) }
    }

    // MARK: - Helper Functions (Minimal working implementations)
    private func isApplyRunning(_ state: ToolRunState) -> Bool {
        if case .running = state { return true }
        return false
    }

    private func applyStatusText(_ state: ToolRunState) -> String {
        if !_isSystemReady { return "System not ready" }
        switch state {
        case .idle: return "Ready"
        case .running(let name): return "Running \(name)…"
        case .success: return "Done"
        case .failed(let msg): return "Failed: \(msg)"
        }
    }

    private func runStartupChecksOnce() {
        // TODO: Restore full startup logic if needed
        autoLoadSideStorePairingIfNeeded()
    }

    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            do {
                let text = try String(contentsOf: url)
                if pairingFile != nil {
                    pendingPairingFileText = text
                    showPairingReplaceConfirm = true
                } else {
                    importPairingFile(text)
                }
            } catch {
                lastError = "Failed to read pairing file: \(error.localizedDescription)"
                showErrorAlert = true
            }
        case .failure(let error):
            lastError = error.localizedDescription
            showErrorAlert = true
        }
    }

    private func importPairingFile(_ text: String) {
        pairingFile = text
        savePairingFileToDocuments(text)
        refreshSystemStatus()
    }

    private func autoLoadSideStorePairingIfNeeded() {
        // TODO: Implement SideStore auto-load if needed
    }

    private func savePairingFileToDocuments(_ text: String) {
        let url = URL.documentsDirectory.appendingPathComponent("pairingFile.plist")
        try? text.write(to: url, atomically: true, encoding: .utf8)
    }

    private func resetPairing() {
        pairingFile = nil
        heartbeatRunning = false
        ddiMounted = false
        viewModel.cancelPairingResetTimer()
    }

    private func refreshSystemStatus() {
        viewModel.refreshSystemStatus(pairingFile: pairingFile) { newState, _ in
            ddiMounted = newState
        }
    }

    private func startNetworkMonitoring() {
        // TODO: Implement network monitoring
    }

    private func stopNetworkMonitoring() {
        // TODO: Implement network monitoring stop
    }

    private func handleScenePhase(_ newPhase: ScenePhase) {
        if newPhase == .active {
            refreshSystemStatus()
        }
    }

    private func handleUUIDCapture() {
        // TODO: Implement UUID capture from Books app
    }

    private func checkForUpdate() {
        // TODO: Implement update check
    }

    private func respringNow() throws {
        try RespringHelper.respring()
    }
}
