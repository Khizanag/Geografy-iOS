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
    }

    // MARK: - Properties
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private let title: String
    private let systemImage: String?
    private let style: Style
    private let trailingSystemImage: String?

    // MARK: - Init
    /// - Parameter trailingSystemImage: A small symbol after the title, such as a chevron on a pill that's a button.
    public init(
        _ title: String,
        systemImage: String? = nil,
        style: Style = .neutral,
        trailingSystemImage: String? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.trailingSystemImage = trailingSystemImage
    }

    // MARK: - Body
    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .accessibilityHidden(true)
            }
            Text(title)
            if let trailingSystemImage {
                Image(systemName: trailingSystemImage)
                    .imageScale(.small)
                    .accessibilityHidden(true)
            }
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
        case .onColor: DesignSystem.Color.onAccent.opacity(DesignSystem.Opacity.tint)
        case .neutral: DesignSystem.Color.cardBackgroundHighlighted
        case .tinted(let color): color.opacity(DesignSystem.Opacity.tint)
        }
    }
}
