import Foundation

// Enum defining all possible settings actions
enum SettingsAction {
    // About actions
    case showVersion
    case checkUpdates
    case openAppStore
    case testAlerts // Test action to cycle through alert types
    
    // Support actions
    case openFAQ
    case contactSupport
    case reportBug
    
    // Legal actions
    case openImpressum
    case openTerms
    case openPrivacy
    
    // Statistics actions
    case deleteStatistics
}



