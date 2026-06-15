//
//  AppURLs.swift
//  Leben in Deutschland
//
//  Centralized URLs for FAQ, legal documents, and support.
//  Marked nonisolated so default init parameters can reference these from any context.
//

import Foundation

enum AppURLs: Sendable {
    private static nonisolated var base: String { "https://www.gizatech.de/hero-einb%C3%BCrgerungstest" }

    nonisolated static var faq: URL? { URL(string: "\(base)/faq") }
    nonisolated static var impressum: URL { URL(string: "\(base)/impressum")! }
    nonisolated static var termsOfUse: URL { URL(string: "\(base)/terms-of-use")! }
    nonisolated static var privacyPolicy: URL { URL(string: "\(base)/privacy-policy")! }
    nonisolated static var contactEmail: String { "info@gizatech.de" }

    nonisolated static let appStoreAppID = "6752272685"
    nonisolated static var appStoreURL: URL { URL(string: "https://apps.apple.com/app/id\(appStoreAppID)")! }
    nonisolated static var appStoreWriteReviewURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appStoreAppID)?action=write-review")!
    }
}
