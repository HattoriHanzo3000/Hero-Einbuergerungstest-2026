import Foundation

struct SettingsSupportMailModel: Identifiable, Equatable {
    let id = UUID()
    let recipients: [String]
    let subject: String
    let body: String
}

