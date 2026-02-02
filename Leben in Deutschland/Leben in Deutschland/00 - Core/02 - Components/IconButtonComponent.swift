//
//  IconButtonComponent.swift
//  Leben in Deutschland
//
//  Reusable circular icon button with adaptive sizing
//

import SwiftUI

// MARK: - Adaptive Icon Button
struct AdaptiveIconButton: View {
    enum SizePreset {
        case standard
        case compact
        case accessibility
        
        func baseControlSize(for dynamicType: DynamicTypeSize) -> CGFloat {
            switch self {
            case .standard:
                switch dynamicType {
                case .xSmall, .small, .medium:
                return 36
                case .large:
                return 38
                case .xLarge:
                return 40
                default:
                return 44
                }
            case .compact:
                switch dynamicType {
                case .xSmall, .small, .medium:
                    return 36
                case .large:
                    return 38
                case .xLarge:
                    return 40
                default:
                    return 44
                }
            case .accessibility:
                switch dynamicType {
                case .xSmall, .small, .medium:
                    return 52
                case .large:
                    return 56
                case .xLarge:
                    return 60
                default:
                    return 64
                }
            }
        }
    }
    
    let systemName: String
    let action: () -> Void
    var accessibilityLabel: String
    var accessibilityHint: String? = nil
    var tintColor: Color = Color(.systemGray6)
    var backgroundColor: Color = Color.white.opacity(0.18)
    var sizePreset: SizePreset = .standard
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            Image(systemName: systemName)
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundColor(tintColor)
                .frame(width: controlSize, height: controlSize)
                .background(
                    Circle()
                        .fill(tintColor.opacity(0.2))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel.localized)
        .accessibilityAddTraits(.isButton)
        .applyAccessibilityHint(accessibilityHint)
    }
    
    private var controlSize: CGFloat {
        layoutMetrics.adaptive(sizePreset.baseControlSize(for: dynamicTypeSize))
    }
}

// MARK: - Factory Helpers
extension AdaptiveIconButton {
    static func backButton(action: @escaping () -> Void) -> AdaptiveIconButton {
        AdaptiveIconButton(
            systemName: "chevron.left",
            action: action,
            accessibilityLabel: "Back",
            accessibilityHint: "Go back",
            tintColor: Color(.systemGray6),
            backgroundColor: Color.white.opacity(0.18),
            sizePreset: .standard
        )
    }
    
    static func dismissButton(action: @escaping () -> Void) -> AdaptiveIconButton {
        AdaptiveIconButton(
            systemName: "chevron.down",
            action: action,
            accessibilityLabel: "Close",
            accessibilityHint: "Dismiss",
            tintColor: Color(.systemGray6),
            backgroundColor: Color.white.opacity(0.18),
            sizePreset: .standard
        )
    }
}

#Preview {
    VStack(spacing: 24) {
        AdaptiveIconButton.backButton {}
        AdaptiveIconButton.dismissButton {}
        AdaptiveIconButton(
            systemName: "magnifyingglass",
            action: {},
            accessibilityLabel: "Search",
            tintColor: .white,
            backgroundColor: Color.blue.opacity(0.3),
            sizePreset: .compact
        )
    }
    .padding()
    .background(Color.black)
}

// MARK: - Accessibility Helper
extension View {
    @ViewBuilder
    func applyAccessibilityHint(_ hint: String?) -> some View {
        if let hint {
            accessibilityHint(hint.localized)
        } else {
            self
        }
    }
}

