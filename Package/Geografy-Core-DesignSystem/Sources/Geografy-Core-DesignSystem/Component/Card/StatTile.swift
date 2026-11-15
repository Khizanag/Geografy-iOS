import SwiftUI

/// One number with its label in a card: the stat box every summary row in the app uses.
///
/// Put two to four in a `StatTileRow` so they share the width and stack at accessibility text sizes.
public struct StatTile: View {
    // MARK: - Properties
    // Symbols differ in glyph height; a fixed slot keeps tiles in a row the same height.
    @ScaledMetric(relativeTo: .headline) private var iconHeight: CGFloat = 24

    private let value: String
    private let label: LocalizedStringKey
    private let icon: String?
    private let color: Color

    // MARK: - Init
    /// - Parameters:
    ///   - value: The number as shown, already formatted: "12", "0/20", "1 200".
    ///   - icon: An SF Symbol tinted with `color`, or nil for a number alone.
    ///   - color: Tints the icon. The number stays in the primary text color, so rows of tiles read evenly.
    public init(
        value: String,
        label: LocalizedStringKey,
        icon: String? = nil,
        color: Color = DesignSystem.Color.accent
    ) {
        self.value = value
        self.label = label
        self.icon = icon
        self.color = color
    }

    // MARK: - Body
    public var body: some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.large) {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                if let icon {
                    Image(systemName: icon)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(color)
                        .frame(height: iconHeight)
                        .accessibilityHidden(true)
                }
                Text(verbatim: value)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(label)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.xs)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text(verbatim: value))
    }
}

/// Stat tiles side by side at equal widths, stacked at accessibility text sizes.
public struct StatTileRow<Content: View>: View {
    // MARK: - Properties
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ViewBuilder private let content: () -> Content

    // MARK: - Init
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    // MARK: - Body
    public var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.sm))
            : AnyLayout(HStackLayout(alignment: .top, spacing: DesignSystem.Spacing.sm))
        layout {
            content()
        }
    }
}
