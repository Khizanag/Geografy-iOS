import SwiftUI

/// A navigation bar button that switches something on the screen on or off, such as map labels.
///
/// A glass circle the size of the bar's other buttons: clear while off, tinted with the accent while on, the
/// look of the system's prominent glass. The bar turns a prominent style into an item of its own, which jumps
/// out of its group and drops the glass, so the circle is drawn here. Hide the bar's shared background for its
/// item with `.sharedBackgroundVisibility(.hidden)`, or it sits inside a second circle.
public struct ToolbarToggle: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title: LocalizedStringKey
    private let systemImage: String
    private let isOn: Bool
    private let action: () -> Void

    // MARK: - Init
    /// - Parameters:
    ///   - title: What the button switches, for VoiceOver: "Country labels".
    ///   - action: Flips the state; the caller owns it, so it can add haptics or persist the choice.
    public init(
        _ title: LocalizedStringKey,
        systemImage: String,
        isOn: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isOn = isOn
        self.action = action
    }

    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(DesignSystem.Font.body)
                .fontWeight(.medium)
                .foregroundStyle(isOn ? DesignSystem.Color.onAccent : DesignSystem.Color.iconPrimary)
                // Fixed, not scaled with text size, to match the bar's other buttons.
                .frame(width: DesignSystem.Size.Button.regular, height: DesignSystem.Size.Button.regular)
                .glassEffect(glass, in: .circle)
                .contentShape(.circle)
                .animation(reduceMotion ? nil : .snappy(duration: 0.25), value: isOn)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text(isOn ? "Shown" : "Hidden"))
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

// MARK: - Helpers
private extension ToolbarToggle {
    var glass: Glass {
        isOn ? .regular.tint(DesignSystem.Color.accent).interactive() : .regular.interactive()
    }
}
