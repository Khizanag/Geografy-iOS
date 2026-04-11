import SwiftUI

/// Animated numeric display. Renders an integer or formatted decimal with
/// `.contentTransition(.numericText(value:))` so the digits roll when the
/// value changes — perfect for XP totals, quiz scores, country counts.
public struct NumericTicker: View {
    public enum Style: Sendable {
        case integer
        case abbreviated
        case currency(code: String)
    }

    private let value: Double
    private let style: Style
    private let font: Font
    private let color: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        _ value: Double,
        style: Style = .integer,
        font: Font = DesignSystem.Font.body,
        color: Color = DesignSystem.Color.textPrimary
    ) {
        self.value = value
        self.style = style
        self.font = font
        self.color = color
    }

    public init(
        _ value: Int,
        style: Style = .integer,
        font: Font = DesignSystem.Font.body,
        color: Color = DesignSystem.Color.textPrimary
    ) {
        self.init(Double(value), style: style, font: font, color: color)
    }

    public var body: some View {
        Text(formatted)
            .font(font)
            .foregroundStyle(color)
            .contentTransition(reduceMotion ? .identity : .numericText(value: value))
            .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.82), value: value)
            .monospacedDigit()
            .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Helpers
private extension NumericTicker {
    var formatted: String {
        switch style {
        case .integer:
            value.formatted(.number.precision(.fractionLength(0)))
        case .abbreviated:
            value.formatted(.number.notation(.compactName))
        case .currency(let code):
            value.formatted(.currency(code: code))
        }
    }

    var accessibilityLabel: String {
        switch style {
        case .integer, .abbreviated: formatted
        case .currency: formatted
        }
    }
}
