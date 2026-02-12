//
//  LearnOptionModel.swift
//  Leben in Deutschland
//
//  Represents a single learning pathway showcased inside the Learn carousel.
//

import SwiftUI

/// Data model describing a selectable learning pathway inside the Learn hub.
struct LearnOptionModel: Identifiable {
    /// Stable identifier used by SwiftUI diffing while scrolling horizontally.
    let id: UUID
    /// Localization key for the option title (displayed in large typography).
    let titleKey: String
    /// Localization key for the option's supporting description.
    let descriptionKey: String
    /// SF Symbol name representing the option with a large, friendly icon.
    let iconSystemName: String
    /// Styling palette that keeps colors consistent between icon and title.
    let palette: LearnOptionPalette
    
    init(
        id: UUID = UUID(),
        titleKey: String,
        descriptionKey: String,
        iconSystemName: String,
        palette: LearnOptionPalette
    ) {
        self.id = id
        self.titleKey = titleKey
        self.descriptionKey = descriptionKey
        self.iconSystemName = iconSystemName
        self.palette = palette
    }
}

/// Encapsulates the color pairing used for each learn option card.
struct LearnOptionPalette {
    /// Gradient colors applied on the card background to add depth.
    let gradientColors: [Color]
    /// Foreground color shared by the title and the icon.
    let accentColor: Color
    
    /// Convenience gradient for SwiftUI rendering.
    var gradient: LinearGradient {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}


