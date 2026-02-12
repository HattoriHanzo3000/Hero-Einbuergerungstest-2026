//
//  AppURLs.swift
//  Leben in Deutschland
//
//  Centralized URLs for FAQ, legal documents, and support.
//  Marked nonisolated so default init parameters can reference these from any context.
//

import Foundation

enum AppURLs: Sendable {
    private static nonisolated var base: String { "https://www.gizatech.de/hero-leben-in-deutschland" }

    nonisolated static var faq: URL? { URL(string: "\(base)/faq") }
    nonisolated static var impressum: URL { URL(string: "\(base)/impressum")! }
    nonisolated static var termsOfUse: URL { URL(string: "\(base)/terms-of-use")! }
    nonisolated static var privacyPolicy: URL { URL(string: "\(base)/privacy-policy")! }
    nonisolated static var contactEmail: String { "info@gizatech.de" }
}
