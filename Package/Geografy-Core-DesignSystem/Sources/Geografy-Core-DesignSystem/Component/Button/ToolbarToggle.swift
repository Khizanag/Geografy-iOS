import SwiftUI

/// A navigation bar button that switches something on the screen on or off, such as map labels.
///
/// While on, an accent disc sits inside the bar's glass circle with a margin all round, so the
/// selection never touches the glass edge.
public struct ToolbarToggle<Content: View>: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title: LocalizedStringKey
    private let isOn: Bool
    private let action: () -> Void
    private let label: Content

    // MARK: - Init
    /// - Parameters:
    ///   - title: What the button switches, for VoiceOver: "Country labels".
    ///   - action: Flips the state; the caller owns it, so it can add haptics or persist the choice.
    public init(
        _ title: LocalizedStringKey,
        isOn: Bool,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Content
    ) {
        self.title = title
        self.isOn = isOn
        self.action = action
        self.label = label()
    }

    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            label
                .font(DesignSystem.Font.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(isOn ? DesignSystem.Color.onAccent : DesignSystem.Color.iconPrimary)
                // Fixed, not scaled with text size: the bar's glass circle doesn't grow, and the disc must stay inside it.
                .frame(width: DesignSystem.Size.Button.compact, height: DesignSystem.Size.Button.compact)
                .background {
                    Circle()
                        .fill(DesignSystem.Color.accent)
                        .opacity(isOn ? 1 : 0)
                }
                // Outside the disc, so the whole glass circle takes the tap. The bar's glass is 44 points,
                // so a 32-point disc keeps a 6-point margin.
                .padding(DesignSystem.Spacing.xs)
                .contentShape(.circle)
                .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: isOn)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text(isOn ? "Shown" : "Hidden"))
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}
