//
//  UITabBarController+Find.swift
//  Leben in Deutschland
//
//  Shared utility to locate UITabBarController in the view hierarchy.
//

import UIKit

extension UITabBarController {
    /// Recursively finds the tab bar controller in the given view controller hierarchy.
    static func find(in viewController: UIViewController?) -> UITabBarController? {
        guard let viewController = viewController else { return nil }
        
        if let tabBarController = viewController as? UITabBarController {
            return tabBarController
        }
        
        for child in viewController.children {
            if let tabBarController = find(in: child) {
                return tabBarController
            }
        }
        
        if let presented = viewController.presentedViewController {
            return find(in: presented)
        }
        
        return nil
    }
}
