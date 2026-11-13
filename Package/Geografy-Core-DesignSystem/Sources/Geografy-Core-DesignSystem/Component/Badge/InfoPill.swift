import SwiftUI

/// A small capsule with an icon and a short fact, such as "12 questions" or "Hard".
public struct InfoPill: View {
    // MARK: - Style
    public enum Style {
        /// On colored or image backgrounds, such as a pack card's gradient.
        case onColor
        /// On the app background or a plain card.
        case neutral
        /// Calls attention, in the accent color.
        case accent
    }

    // MARK: - Properties
    private let title: String
    private let systemImage: String?
    private let style: Style

    // MARK: - Init
    public init(_ title: String, systemImage: String? = nil, style: Style = .neutral) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
    }

    // MARK: - Body
    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .accessibilityHidden(true)
            }
            Text(title)
        }
        .font(DesignSystem.Font.caption2)
        .fontWeight(.semibold)
        .foregroundStyle(foreground)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(background, in: Capsule())
    }
}

// MARK: - Helpers
private extension InfoPill {
    var foreground: Color {
        switch style {
        case .onColor: DesignSystem.Color.onAccent
        case .neutral: DesignSystem.Color.textSecondary
        case .accent: DesignSystem.Color.accent
        }
    }

    var background: Color {
        switch style {
        case .onColor: DesignSystem.Color.onAccent.opacity(0.18)
        case .neutral: DesignSystem.Color.cardBackgroundHighlighted
        case .accent: DesignSystem.Color.accent.opacity(0.15)
        }
    }
}
