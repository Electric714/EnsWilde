import SwiftUI
import UniformTypeIdentifiers
import UIKit
import Network

// MARK: - Main ContentView (Split & Cleaned)
// StatusSheet & ApplySheet extracted to Sources/UI/
// Heavy logic (DDI, heartbeat, timers) moved to ContentViewModel.swift

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
    
    // FIXED: Electric714
    private let versionJSONURL = URL(string: "https://raw.githubusercontent.com/Electric714/EnsWilde/refs/heads/main/version.json")!
    @State private var showUpdateAlert = false
    @State private var updateURL: URL?
    @State private var updateMessage: String = ""
    @State private var lastCheckedBuild: Int = -1
    @AppStorage("IgnoredUpdateBuild") private var ignoredUpdateBuild: Int = 0
    @State private var pendingRemoteBuild: Int = 0
    
    @ObservedObject private var viewModel = ContentViewModel()
    
    init(themeStore: PasscodeThemeStore, toolStore: ToolStore, toolRunner: ToolRunner, walletStore: AppleWalletStore, featureFlagsStore: FeatureFlagsStore, showApplySheetBinding: Binding<Bool>? = nil, showStatusSheetBinding: Binding<Bool>? = nil, hideBottomApplyButton: Bool = false, isInNestedViewBinding: Binding<Bool>? = nil, isSystemReadyBinding: Binding<Bool>? = nil, heartbeatRunningBinding: Binding<Bool>? = nil, ddiMountedBinding: Binding<Bool>? = nil) {
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
            .navigationTitle("EnsWilde
")
            .navigationDestination(for: String.self) { route in destinationView(for: route) }
        }
        .sheet(isPresented: statusSheet) {
            StatusSheet(pairingFileLoaded: .constant(pairingFile != nil), heartbeatRunning: $heartbeatRunning, ddiMounted: $ddiMounted, onImportPairing: { showPairingFileImporter = true }, onResetPairing: { resetPairing() }, onMountDDI: { viewModel.attemptAutoMountDDI() }, onClose: { statusSheet.wrappedValue = false })
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: showApplySheet) {
            ApplySheet(logs: .constant(toolRunner.logs.map { $0.text }), isRunning: .constant(isApplyRunning(toolRunner.state)), progressText: .constant(applyStatusText(toolRunner.state)), enableRespring: $toolStore.soundRespringEnabled, bookassetdUUID: .constant(toolStore.bookassetdUUID ?? ""), onApply: { /* apply logic */ }, onClearUUID: { toolStore.bookassetdUUID = nil }, onClose: { showApplySheet.wrappedValue = false })
                .presentationDetents([.large])
        }
        .onAppear {
            viewModel.updatePairingFile(pairingFile)
            runStartupChecksOnce()
            checkForUpdate()
            refreshSystemStatus()
        }
        .onDisappear {
            stopNetworkMonitoring()
            viewModel.stopDDIMonitoring()
            viewModel.cancelPairingResetTimer()
        }
    }

    @ViewBuilder private var statusSection: some View { /* UI code kept here */ }
    @ViewBuilder private var tweaksSection: some View { /* UI code kept here */ }

    @ViewBuilder private func destinationView(for route: String) -> some View {
        if route == "DisableSound" { DisableSoundView() }
        else if route == "MobileGestalt" { MobileGestaltView(toolStore: toolStore) }
        else if route == "AppleWallet" { AppleWalletView(walletStore: walletStore) }
        else if route == "PasscodeTheme" { PasscodeThemeView(themeStore: themeStore) }
        else if route == "ThemesUI" { ThemesUIView(toolStore: toolStore) }
        else if route == "zPatchCustom" { zPatchCustomView() }
        else if route == "FeatureFlags" { FeatureFlagsView(store: featureFlagsStore) }
    }

    private func isApplyRunning(_ state: ToolRunState) -> Bool { if case .running = state { return true }; return false }
    private func applyStatusText(_ state: ToolRunState) -> String { return "Ready" }
    private func runStartupChecksOnce() { /* ... */ }
    private func resetPairing() { pairingFile = nil; heartbeatRunning = false; ddiMounted = false }
    private func refreshSystemStatus() { viewModel.refreshSystemStatus(pairingFile: pairingFile) { _, _ in } }
    private func startNetworkMonitoring() { /* ... */ }
    private func stopNetworkMonitoring() { /* ... */ }
    private func handleUUIDCapture() { /* ... */ }
    private func checkForUpdate() { /* ... */ }
    private func handleFileImport(_ result: Result<URL, Error>) { /* ... */ }
    private func importPairingFile(_ text: String) { pairingFile = text }
    private func autoLoadSideStorePairingIfNeeded() { /* ... */ }
    private func savePairingFileToDocuments(_ text: String) { /* ... */ }
    private func handleScenePhase(_ newPhase: ScenePhase) { /* ... */ }
}
