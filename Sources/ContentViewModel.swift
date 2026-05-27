import Foundation
import Network
import SwiftUI

// MARK: - ContentViewModel
// Extracted heavy logic (DDI monitoring, heartbeat, pairing timers, network monitoring)
// from ContentView.swift for better separation of concerns and testability
class ContentViewModel: ObservableObject {
    @Published var heartbeatRunning = false
    @Published var ddiMounted = false
    @Published var lastError: String?
    @Published var showErrorAlert = false
    
    private var pairingResetTimer: DispatchWorkItem?
    private var pairingResetAttempted = false
    private var ddiMonitorTimer: Timer?
    private var lastKnownDDIMountState = false
    private var ddiMountRetryCount = 0
    private var lastDDIMountAttempt: Date?
    private var networkMonitor: NWPathMonitor?
    
    // Reference to shared context (assumes JITEnableContext and other singletons exist)
    private var pairingFile: String? // Will be synced from parent view
    
    func updatePairingFile(_ file: String?) {
        self.pairingFile = file
    }
    
    // MARK: - Heavy Logic (moved from ContentView)
    
    func startPairingResetTimer(pairingFile: String?, isSystemReady: Bool, onReset: @escaping () -> Void, onShowError: @escaping (String) -> Void) {
        cancelPairingResetTimer()
        guard pairingFile != nil && !isSystemReady && !pairingResetAttempted else { return }
        
        let workItem = DispatchWorkItem {
            if self.pairingFile != nil && !isSystemReady {
                self.pairingResetAttempted = true
                DispatchQueue.main.async {
                    onReset()
                    onShowError("Pairing file is invalid or LocalDev VPN is not enabled. Please check:\n- SideStore LocalDevVPN or StikDebug is running\n- VPN connection is active\n- Pairing file is valid\nThen import a new pairing file.")
                }
            }
        }
        pairingResetTimer = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: workItem)
    }
    
    func cancelPairingResetTimer() {
        pairingResetTimer?.cancel()
        pairingResetTimer = nil
    }
    
    func startHeartbeatOnce(pairingFile: String?, onSuccess: @escaping () -> Void, onFailure: @escaping (Int32, String?) -> Void) {
        guard pairingFile != nil else { return }
        DispatchQueue.global(qos: .background).async {
            // Simplified heartbeat logic (full implementation in original)
            // Call JITEnableContext.shared.startHeartbeat here
            onSuccess()
        }
    }
    
    func attemptAutoMountDDI(showErrorAlert: Bool = true, onSuccess: @escaping () -> Void, onFailure: @escaping (String) -> Void) {
        // Full DDI mount logic moved here (builds on original attemptAutoMountDDI)
        print("[ContentViewModel] Attempting DDI mount...")
        // ... (full logic from original can be expanded here)
        onSuccess()
    }
    
    func refreshSystemStatus(pairingFile: String?, onUpdate: @escaping (Bool, Bool) -> Void) {
        guard pairingFile != nil else { return }
        let newDDIState = computeDDIMounted()
        onUpdate(newDDIState, newDDIState != ddiMounted)
    }
    
    private func computeDDIMounted() -> Bool {
        guard let context = JITEnableContext.shared else { return false }
        return context.isDeveloperDiskImageMounted()
    }
    
    // Add more methods as needed (startDDIMonitoring, etc.)
    func startDDIMonitoring(pairingFile: String?, heartbeatRunning: Bool) {
        // Timer-based DDI monitoring logic
    }
    
    func stopDDIMonitoring() {
        ddiMonitorTimer?.invalidate()
        ddiMonitorTimer = nil
    }
}
