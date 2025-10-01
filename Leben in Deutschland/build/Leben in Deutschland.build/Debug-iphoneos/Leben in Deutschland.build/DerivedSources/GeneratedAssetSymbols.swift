import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "AccentColor" asset catalog color resource.
    static let accent = DeveloperToolsSupport.ColorResource(name: "AccentColor", bundle: resourceBundle)

    /// The "AppGreen" asset catalog color resource.
    static let appGreen = DeveloperToolsSupport.ColorResource(name: "AppGreen", bundle: resourceBundle)

    /// The "AppOrange" asset catalog color resource.
    static let appOrange = DeveloperToolsSupport.ColorResource(name: "AppOrange", bundle: resourceBundle)

    /// The "AppPink" asset catalog color resource.
    static let appPink = DeveloperToolsSupport.ColorResource(name: "AppPink", bundle: resourceBundle)

    /// The "AppRed" asset catalog color resource.
    static let appRed = DeveloperToolsSupport.ColorResource(name: "AppRed", bundle: resourceBundle)

    /// The "AppYellow" asset catalog color resource.
    static let appYellow = DeveloperToolsSupport.ColorResource(name: "AppYellow", bundle: resourceBundle)

    /// The "Block" asset catalog color resource.
    static let block = DeveloperToolsSupport.ColorResource(name: "Block", bundle: resourceBundle)

    /// The "CategoryButton" asset catalog color resource.
    static let categoryButton = DeveloperToolsSupport.ColorResource(name: "CategoryButton", bundle: resourceBundle)

    /// The "CategoryText" asset catalog color resource.
    static let categoryText = DeveloperToolsSupport.ColorResource(name: "CategoryText", bundle: resourceBundle)

    /// The "Correct" asset catalog color resource.
    static let correct = DeveloperToolsSupport.ColorResource(name: "Correct", bundle: resourceBundle)

    /// The "CorrectCircle" asset catalog color resource.
    static let correctCircle = DeveloperToolsSupport.ColorResource(name: "CorrectCircle", bundle: resourceBundle)

    /// The "Fill" asset catalog color resource.
    static let fill = DeveloperToolsSupport.ColorResource(name: "Fill", bundle: resourceBundle)

    /// The "Selected" asset catalog color resource.
    static let selected = DeveloperToolsSupport.ColorResource(name: "Selected", bundle: resourceBundle)

    /// The "SelectedCircle" asset catalog color resource.
    static let selectedCircle = DeveloperToolsSupport.ColorResource(name: "SelectedCircle", bundle: resourceBundle)

    /// The "Unselected" asset catalog color resource.
    static let unselected = DeveloperToolsSupport.ColorResource(name: "Unselected", bundle: resourceBundle)

    /// The "Wrong" asset catalog color resource.
    static let wrong = DeveloperToolsSupport.ColorResource(name: "Wrong", bundle: resourceBundle)

    /// The "WrongCircle" asset catalog color resource.
    static let wrongCircle = DeveloperToolsSupport.ColorResource(name: "WrongCircle", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "Logo" asset catalog image resource.
    static let logo = DeveloperToolsSupport.ImageResource(name: "Logo", bundle: resourceBundle)

    /// The "MainChick" asset catalog image resource.
    static let mainChick = DeveloperToolsSupport.ImageResource(name: "MainChick", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "AccentColor" asset catalog color.
    static var accent: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .accent)
#else
        .init()
#endif
    }

    /// The "AppGreen" asset catalog color.
    static var appGreen: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .appGreen)
#else
        .init()
#endif
    }

    /// The "AppOrange" asset catalog color.
    static var appOrange: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .appOrange)
#else
        .init()
#endif
    }

    /// The "AppPink" asset catalog color.
    static var appPink: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .appPink)
#else
        .init()
#endif
    }

    /// The "AppRed" asset catalog color.
    static var appRed: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .appRed)
#else
        .init()
#endif
    }

    /// The "AppYellow" asset catalog color.
    static var appYellow: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .appYellow)
#else
        .init()
#endif
    }

    /// The "Block" asset catalog color.
    static var block: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .block)
#else
        .init()
#endif
    }

    /// The "CategoryButton" asset catalog color.
    static var categoryButton: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .categoryButton)
#else
        .init()
#endif
    }

    /// The "CategoryText" asset catalog color.
    static var categoryText: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .categoryText)
#else
        .init()
#endif
    }

    /// The "Correct" asset catalog color.
    static var correct: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .correct)
#else
        .init()
#endif
    }

    /// The "CorrectCircle" asset catalog color.
    static var correctCircle: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .correctCircle)
#else
        .init()
#endif
    }

    /// The "Fill" asset catalog color.
    static var fill: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fill)
#else
        .init()
#endif
    }

    /// The "Selected" asset catalog color.
    static var selected: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .selected)
#else
        .init()
#endif
    }

    /// The "SelectedCircle" asset catalog color.
    static var selectedCircle: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .selectedCircle)
#else
        .init()
#endif
    }

    /// The "Unselected" asset catalog color.
    static var unselected: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .unselected)
#else
        .init()
#endif
    }

    /// The "Wrong" asset catalog color.
    static var wrong: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .wrong)
#else
        .init()
#endif
    }

    /// The "WrongCircle" asset catalog color.
    static var wrongCircle: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .wrongCircle)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "AccentColor" asset catalog color.
    static var accent: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .accent)
#else
        .init()
#endif
    }

    /// The "AppGreen" asset catalog color.
    static var appGreen: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .appGreen)
#else
        .init()
#endif
    }

    /// The "AppOrange" asset catalog color.
    static var appOrange: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .appOrange)
#else
        .init()
#endif
    }

    /// The "AppPink" asset catalog color.
    static var appPink: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .appPink)
#else
        .init()
#endif
    }

    /// The "AppRed" asset catalog color.
    static var appRed: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .appRed)
#else
        .init()
#endif
    }

    /// The "AppYellow" asset catalog color.
    static var appYellow: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .appYellow)
#else
        .init()
#endif
    }

    /// The "Block" asset catalog color.
    static var block: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .block)
#else
        .init()
#endif
    }

    /// The "CategoryButton" asset catalog color.
    static var categoryButton: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .categoryButton)
#else
        .init()
#endif
    }

    /// The "CategoryText" asset catalog color.
    static var categoryText: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .categoryText)
#else
        .init()
#endif
    }

    /// The "Correct" asset catalog color.
    static var correct: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .correct)
#else
        .init()
#endif
    }

    /// The "CorrectCircle" asset catalog color.
    static var correctCircle: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .correctCircle)
#else
        .init()
#endif
    }

    /// The "Fill" asset catalog color.
    static var fill: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .fill)
#else
        .init()
#endif
    }

    /// The "Selected" asset catalog color.
    static var selected: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .selected)
#else
        .init()
#endif
    }

    /// The "SelectedCircle" asset catalog color.
    static var selectedCircle: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .selectedCircle)
#else
        .init()
#endif
    }

    /// The "Unselected" asset catalog color.
    static var unselected: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .unselected)
#else
        .init()
#endif
    }

    /// The "Wrong" asset catalog color.
    static var wrong: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .wrong)
#else
        .init()
#endif
    }

    /// The "WrongCircle" asset catalog color.
    static var wrongCircle: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .wrongCircle)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "AccentColor" asset catalog color.
    static var accent: SwiftUI.Color { .init(.accent) }

    /// The "AppGreen" asset catalog color.
    static var appGreen: SwiftUI.Color { .init(.appGreen) }

    /// The "AppOrange" asset catalog color.
    static var appOrange: SwiftUI.Color { .init(.appOrange) }

    /// The "AppPink" asset catalog color.
    static var appPink: SwiftUI.Color { .init(.appPink) }

    /// The "AppRed" asset catalog color.
    static var appRed: SwiftUI.Color { .init(.appRed) }

    /// The "AppYellow" asset catalog color.
    static var appYellow: SwiftUI.Color { .init(.appYellow) }

    /// The "Block" asset catalog color.
    static var block: SwiftUI.Color { .init(.block) }

    /// The "CategoryButton" asset catalog color.
    static var categoryButton: SwiftUI.Color { .init(.categoryButton) }

    /// The "CategoryText" asset catalog color.
    static var categoryText: SwiftUI.Color { .init(.categoryText) }

    /// The "Correct" asset catalog color.
    static var correct: SwiftUI.Color { .init(.correct) }

    /// The "CorrectCircle" asset catalog color.
    static var correctCircle: SwiftUI.Color { .init(.correctCircle) }

    /// The "Fill" asset catalog color.
    static var fill: SwiftUI.Color { .init(.fill) }

    /// The "Selected" asset catalog color.
    static var selected: SwiftUI.Color { .init(.selected) }

    /// The "SelectedCircle" asset catalog color.
    static var selectedCircle: SwiftUI.Color { .init(.selectedCircle) }

    /// The "Unselected" asset catalog color.
    static var unselected: SwiftUI.Color { .init(.unselected) }

    /// The "Wrong" asset catalog color.
    static var wrong: SwiftUI.Color { .init(.wrong) }

    /// The "WrongCircle" asset catalog color.
    static var wrongCircle: SwiftUI.Color { .init(.wrongCircle) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "AccentColor" asset catalog color.
    static var accent: SwiftUI.Color { .init(.accent) }

    /// The "AppGreen" asset catalog color.
    static var appGreen: SwiftUI.Color { .init(.appGreen) }

    /// The "AppOrange" asset catalog color.
    static var appOrange: SwiftUI.Color { .init(.appOrange) }

    /// The "AppPink" asset catalog color.
    static var appPink: SwiftUI.Color { .init(.appPink) }

    /// The "AppRed" asset catalog color.
    static var appRed: SwiftUI.Color { .init(.appRed) }

    /// The "AppYellow" asset catalog color.
    static var appYellow: SwiftUI.Color { .init(.appYellow) }

    /// The "Block" asset catalog color.
    static var block: SwiftUI.Color { .init(.block) }

    /// The "CategoryButton" asset catalog color.
    static var categoryButton: SwiftUI.Color { .init(.categoryButton) }

    /// The "CategoryText" asset catalog color.
    static var categoryText: SwiftUI.Color { .init(.categoryText) }

    /// The "Correct" asset catalog color.
    static var correct: SwiftUI.Color { .init(.correct) }

    /// The "CorrectCircle" asset catalog color.
    static var correctCircle: SwiftUI.Color { .init(.correctCircle) }

    /// The "Fill" asset catalog color.
    static var fill: SwiftUI.Color { .init(.fill) }

    /// The "Selected" asset catalog color.
    static var selected: SwiftUI.Color { .init(.selected) }

    /// The "SelectedCircle" asset catalog color.
    static var selectedCircle: SwiftUI.Color { .init(.selectedCircle) }

    /// The "Unselected" asset catalog color.
    static var unselected: SwiftUI.Color { .init(.unselected) }

    /// The "Wrong" asset catalog color.
    static var wrong: SwiftUI.Color { .init(.wrong) }

    /// The "WrongCircle" asset catalog color.
    static var wrongCircle: SwiftUI.Color { .init(.wrongCircle) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "Logo" asset catalog image.
    static var logo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logo)
#else
        .init()
#endif
    }

    /// The "MainChick" asset catalog image.
    static var mainChick: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainChick)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "Logo" asset catalog image.
    static var logo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logo)
#else
        .init()
#endif
    }

    /// The "MainChick" asset catalog image.
    static var mainChick: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mainChick)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

