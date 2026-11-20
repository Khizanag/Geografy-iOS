import SwiftUI

/// A navigation bar button that switches something on the screen on or off, such as map labels.
///
/// While on, it takes the system's prominent glass, tinted with the accent; while off, it's a plain bar button.
public struct ToolbarToggle<Content: View>: View {
    // MARK: - Properties
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
        if isOn {
            button
                .buttonStyle(.glassProminent)
                .tint(DesignSystem.Color.accent)
        } else {
            button
        }
    }
}

// MARK: - Subviews
private extension ToolbarToggle {
    var button: some View {
        Button(action: action) {
            label
                .lineLimit(1)
        }
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text(isOn ? "Shown" : "Hidden"))
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}
