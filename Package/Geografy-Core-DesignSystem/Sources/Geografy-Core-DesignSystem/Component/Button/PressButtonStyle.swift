import SwiftUI

/// The style of a card or tile that is itself the button, as article 12 asks: the whole item takes the tap, dims a
/// little and settles back while pressed, lifts under a pointer, and fades when disabled. A standalone button is
/// glass instead (`GlassButton`, `.buttonStyle(.glass)`); this style is for content that acts.
///
/// A press plays no haptic: a haptic confirms a change of state (article 23), and the screen the tap changes plays
/// its own.
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
    }

    var opacity: Double {
        guard isEnabled else { return DesignSystem.Opacity.half }
        return configuration.isPressed ? 0.85 : 1.0
    }
}
