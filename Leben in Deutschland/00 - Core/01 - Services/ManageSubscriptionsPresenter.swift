import StoreKit
import UIKit

enum ManageSubscriptionsPresenter {
    @MainActor
    static func presentSystemManageSubscriptions() async -> Bool {
        guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
            return false
        }
        do {
            try await AppStore.showManageSubscriptions(in: scene)
            return true
        } catch {
            return false
        }
    }
}
