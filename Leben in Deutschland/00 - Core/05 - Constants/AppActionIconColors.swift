//
//  AppActionIconColors.swift
//  Leben in Deutschland
//
//  Single source of truth for quiz/action bar icon colors (footer, header).
//  Change a color here to update it across the app.
//

import SwiftUI

/// Central colors for action bar icons (translation, favorite, etc.). Edit here to change globally.
enum AppActionIconColors {
    /// Translation (globe) icon when active.
    static let translationActive = Color("AppCaribean")
    /// Favorite (heart) icon when active.
    static let favoriteActive = Color("AppPink")
}
