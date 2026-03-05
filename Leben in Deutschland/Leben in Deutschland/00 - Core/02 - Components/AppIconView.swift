//
//  AppIconView.swift
//  Leben in Deutschland
//
//  Displays the app's actual icon (the one shown on the home screen).
//  Loads from the bundle via CFBundleIconFiles. Requires build setting
//  ASSETCATALOG_COMPILER_STANDALONE_ICON_BEHAVIOR = all for iOS 18+.
//

import SwiftUI
import UIKit

/// Displays the app icon as shown on the home screen. Loads from the bundle.
struct AppIconView: View {
    var cornerRadius: CGFloat = 36
    var accessibilityLabel: String = "App-Icon"

    private var appIconImage: UIImage? {
        // 1. Try CFBundleIconFiles (last = largest, e.g. 1024pt)
        if let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let files = primary["CFBundleIconFiles"] as? [String],
           let name = files.last,
           let img = UIImage(named: name) {
            return img
        }
        // 2. Try explicit 1024pt (exposed when STANDALONE_ICON_BEHAVIOR = all)
        if let img = UIImage(named: "AppIcon1024x1024") {
            return img
        }
        // 3. Legacy: AppIcon (nil on iOS 18+ with default build)
        if let img = UIImage(named: "AppIcon") {
            return img
        }
        return nil
    }

    var body: some View {
        Group {
            if let image = appIconImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            } else {
                EmptyView()
            }
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    AppIconView()
        .frame(width: 120, height: 120)
}
