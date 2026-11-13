import SwiftUI

/// A small capsule with an icon and a short fact, such as "12 questions" or "Hard".
public struct InfoPill: View {
    // MARK: - Style
    public enum Style {
        /// On colored or image backgrounds, such as a pack card's gradient.
        case onColor
        /// On the app background or a plain card.
        case neutral
        /// In a color that carries meaning, such as an organization's color or a site type's.
        case tinted(Color)

        /// Calls attention, in the accent color.
        public static var accent: Style { .tinted(DesignSystem.Color.accent) }
    }

    // MARK: - Properties
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

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
        .overlay {
            // A faint tint alone can vanish at increased contrast, so the pill gets an edge.
            if colorSchemeContrast == .increased {
                Capsule().strokeBorder(DesignSystem.Color.dividerSubtle)
            }
        }
    }
}

// MARK: - Helpers
private extension InfoPill {
    var foreground: Color {
        switch style {
        case .onColor: DesignSystem.Color.onAccent
        case .neutral: DesignSystem.Color.textSecondary
        case .tinted(let color): color
        }
    }

    var background: Color {
        switch style {
        case .onColor: DesignSystem.Color.onAccent.opacity(0.18)
        case .neutral: DesignSystem.Color.cardBackgroundHighlighted
        case .tinted(let color): color.opacity(0.15)
        }
    }
}
