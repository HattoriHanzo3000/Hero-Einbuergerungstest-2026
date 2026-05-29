import SwiftUI

// MARK: - Tab Bar View
/// Compatibility wrapper. Use `MainView` as the app's root tab container.
struct TabBarView: View {
    var body: some View {
        MainView()
    }
}

// MARK: - Preview
#Preview("Tab Bar View") {
    TabBarView()
        .environmentObject(LanguageManager())
        .environmentObject(StateManager.shared)
        .environmentObject(SoundManager.shared)
        .environmentObject(AppFlow())
        .environmentObject(SubscriptionManager.shared)
        .environmentObject(FavoritesManager.shared)
}
