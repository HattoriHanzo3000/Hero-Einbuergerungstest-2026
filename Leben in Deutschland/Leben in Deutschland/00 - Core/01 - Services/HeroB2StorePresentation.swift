//
//  HeroB2StorePresentation.swift
//  Leben in Deutschland
//
//  Presents the cross-promo App Store product page for Hero B2.
//

import StoreKit
import UIKit

enum HeroB2AppStore {
    static let productID = NSNumber(value: 6755700752)
}

// MARK: - SKStoreProductViewController (single UIKit modal from topmost VC)
enum HeroB2StorePresentation {
    private static var retainedDelegate: HeroB2StoreProductDelegate?

    @MainActor
    static func present() {
        guard let presenter = UIApplication.shared.lid_topMostViewController else { return }

        HapticManager.shared.lightImpact()

        let storeVC = SKStoreProductViewController()
        let delegate = HeroB2StoreProductDelegate {
            retainedDelegate = nil
        }
        retainedDelegate = delegate
        storeVC.delegate = delegate

        let params: [String: Any] = [
            SKStoreProductParameterITunesItemIdentifier: HeroB2AppStore.productID
        ]

        storeVC.loadProduct(withParameters: params) { loaded, _ in
            DispatchQueue.main.async {
                if loaded {
                    presenter.present(storeVC, animated: true)
                } else {
                    retainedDelegate = nil
                }
            }
        }
    }
}

final class HeroB2StoreProductDelegate: NSObject, SKStoreProductViewControllerDelegate {
    private let onTeardown: () -> Void

    init(onTeardown: @escaping () -> Void) {
        self.onTeardown = onTeardown
    }

    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true) { [onTeardown] in
            onTeardown()
        }
    }
}

private extension UIApplication {
    var lid_topMostViewController: UIViewController? {
        guard
            let scene = connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let root = scene.windows.first(where: \.isKeyWindow)?.rootViewController
        else {
            return nil
        }
        return lid_topMost(from: root)
    }

    func lid_topMost(from viewController: UIViewController) -> UIViewController {
        if let nav = viewController as? UINavigationController,
           let visible = nav.visibleViewController {
            return lid_topMost(from: visible)
        }
        if let tab = viewController as? UITabBarController,
           let selected = tab.selectedViewController {
            return lid_topMost(from: selected)
        }
        if let presented = viewController.presentedViewController {
            return lid_topMost(from: presented)
        }
        return viewController
    }
}
