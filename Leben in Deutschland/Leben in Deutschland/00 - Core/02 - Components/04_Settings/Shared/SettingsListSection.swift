import SwiftUI

/// Wrapper around SwiftUI Section that applies iOS 26 glass list styling.
struct SettingsListSection<Content: View>: View {
    let titleKey: String
    let content: Content
    
    init(titleKey: String, @ViewBuilder content: () -> Content) {
        self.titleKey = titleKey
        self.content = content()
    }
    
    var body: some View {
        Section {
            content
        } header: {
            Text(titleKey.localized)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, MainScreenConstants.adaptiveValue(8))
                .padding(.bottom, MainScreenConstants.adaptiveValue(6))
        }
        .listSectionSpacing(.compact)
    }
}

