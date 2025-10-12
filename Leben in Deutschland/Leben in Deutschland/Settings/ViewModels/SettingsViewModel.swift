import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // Toggle states
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "sound_enabled")
        }
    }
    
    @Published var isVibrationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isVibrationEnabled, forKey: "vibration_enabled")
        }
    }
    
    // Appearance mode - uses @AppStorage for immediate sync
    @Published var appearanceMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: "app_appearance")
        }
    }
    
    // Sheet states
    @Published var showVersionSheet = false
    @Published var showContactMail = false
    @Published var showBugReportMail = false
    @Published var showDeleteWarning = false
    
    // Alert states
    @Published var showUpdateAlert = false
    @Published var updateAlertTitle = ""
    @Published var updateAlertMessage = ""
    
    // Test counter for cycling through alert types
    private var testAlertCounter = 0
    
    // MARK: - Initialization
    
    init() {
        // Load saved settings or use defaults
        self.isSoundEnabled = UserDefaults.standard.object(forKey: "sound_enabled") as? Bool ?? true
        self.isVibrationEnabled = UserDefaults.standard.object(forKey: "vibration_enabled") as? Bool ?? true
        
        let savedAppearance = UserDefaults.standard.string(forKey: "app_appearance") ?? "system"
        self.appearanceMode = AppearanceMode(from: savedAppearance)
        
        // Initialize defaults if first launch
        initializeDefaultSettings()
    }
    
    // MARK: - Methods
    
    // Initialize default settings on first launch
    private func initializeDefaultSettings() {
        if !UserDefaults.standard.bool(forKey: "settings_initialized") {
            UserDefaults.standard.set(true, forKey: "sound_enabled")
            UserDefaults.standard.set(true, forKey: "vibration_enabled")
            UserDefaults.standard.set(true, forKey: "settings_initialized")
        }
    }
    
    // Toggle sound
    func toggleSound() {
        HapticManager.shared.lightImpact()
        isSoundEnabled.toggle()
    }
    
    // Toggle vibration
    func toggleVibration() {
        HapticManager.shared.lightImpact()
        isVibrationEnabled.toggle()
    }
    
    // Cycle appearance mode
    func cycleAppearance() {
        HapticManager.shared.lightImpact()
        appearanceMode = appearanceMode.next
    }
    
    // Handle action execution
    func handleAction(_ action: SettingsAction) {
        HapticManager.shared.lightImpact()
        
        switch action {
        case .showVersion:
            showVersionSheet = true
            
        case .checkUpdates:
            checkForUpdates()
            
        case .openAppStore:
            openAppStoreLink()
            
        case .testAlerts:
            showTestAlert()
            
        case .openFAQ:
            openURL("https://www.gizatech.de/hero/faq")
            
        case .contactSupport:
            showContactMail = true
            
        case .reportBug:
            showBugReportMail = true
            
        case .openImpressum:
            openURL("https://www.gizatech.de/hero/impressum")
            
        case .openTerms:
            openURL("https://www.gizatech.de/hero/terms-of-use")
            
        case .openPrivacy:
            openURL("https://www.gizatech.de/hero/privacy-policy")
            
        case .deleteStatistics:
            HapticManager.shared.heavyImpact()
            showDeleteWarning = true
        }
    }
    
    // Check for updates
    func checkForUpdates() {
        // TODO: In production, integrate with App Store API to check for actual updates
        // For now, show "up to date" message
        
        // Simulate a brief delay for checking
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // For now, always show "up to date" message
            // In production, compare App Store version with current version
            self.updateAlertTitle = "update_latest_title".localized
            self.updateAlertMessage = "update_latest_message".localized
            self.showUpdateAlert = true
        }
    }
    
    // Test different alert types (for development/testing)
    func showTestAlert() {
        testAlertCounter = (testAlertCounter + 1) % 3
        
        switch testAlertCounter {
        case 0:
            // Up to date
            updateAlertTitle = "update_latest_title".localized
            updateAlertMessage = "update_latest_message".localized
        case 1:
            // Update available
            updateAlertTitle = "update_title".localized
            updateAlertMessage = "update_message".localized
        case 2:
            // Update required
            updateAlertTitle = "update_required_title".localized
            updateAlertMessage = "update_required_message".localized
        default:
            break
        }
        
        showUpdateAlert = true
    }
    
    // Open App Store link
    private func openAppStoreLink() {
        // Open direct App Store link
        let appStoreURL = "https://apps.apple.com/app/id6752272685"
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url)
        }
    }
    
    // Open URL in Safari
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    // Confirm statistics deletion
    func confirmDelete(onComplete: @escaping () -> Void) {
        HapticManager.shared.heavyImpact()
        
        // Clear all UserDefaults except critical keys
        let criticalKeys = ["settings_initialized", "hasCompletedOnboarding"]
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        dictionary.keys.forEach { key in
            if !criticalKeys.contains(key) {
                defaults.removeObject(forKey: key)
            }
        }
        
        defaults.synchronize()
        
        // Reset to defaults
        isSoundEnabled = true
        isVibrationEnabled = true
        appearanceMode = .system
        
        showDeleteWarning = false
        
        // Call completion to trigger app restart
        onComplete()
    }
    
    // Get app version string
    func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return version
    }
    
    // Get device info for support emails
    func getDeviceInfo() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        
        return """
        
        Please do not delete the device information below as it helps us provide better support.
        
        --- Device Information ---
        App Version: \(appVersion) (\(buildNumber))
        Device: \(deviceModel)
        iOS Version: \(systemName) \(systemVersion)
        
        --- Please describe your problem or inquiry below ---
        
        """
    }
}

