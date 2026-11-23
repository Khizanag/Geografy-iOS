import SwiftUI

/// The style of a card or tile that is itself the button, as article 12 asks: the whole item takes the tap, dims a
/// little and settles back while pressed, taps lightly at half strength, lifts under a pointer, and fades when
/// disabled. A standalone button is glass instead (`GlassButton`, `.buttonStyle(.glass)`); this style is for
/// content that acts.
public struct PressButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        PressButtonBody(configuration: configuration)
    }
}

// MARK: - Body
private struct PressButtonBody: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    let configuration: ButtonStyleConfiguration

    var body: some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1.0)
            .opacity(opacity)
            .animation(
                reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.7),
                value: configuration.isPressed
            )
            .hoverEffect(.lift)
            .haptic(trigger: configuration.isPressed) { _, isPressed in
                isPressed ? .impact(weight: .light, intensity: 0.5) : nil
            }
    }

    var opacity: Double {
        guard isEnabled else { return DesignSystem.Opacity.half }
        return configuration.isPressed ? 0.85 : 1.0
    }
}
