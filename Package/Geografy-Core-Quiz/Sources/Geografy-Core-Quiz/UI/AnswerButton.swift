import Geografy_Core_DesignSystem
import SwiftUI

/// Reusable answer-button with built-in feedback motion + haptic + sound.
///
/// Call sites supply the displayed content and an action. The button infers
/// its post-tap state from an optional `feedback` parameter: when set to
/// `.correct` or `.wrong`, the button scales / flashes / plays the matching
/// SFX and haptic. The caller is expected to render the rest of the feedback
/// UI (disabling other options, revealing the right answer, etc).
public struct AnswerButton<Label: View>: View {
    public enum Feedback: Sendable, Equatable {
        case none
        case correct
        case wrong
        /// Shown on the non-selected correct option after the user got it wrong,
        /// so the player sees which one they missed.
        case reveal
    }

    private let feedback: Feedback
    private let action: () -> Void
    private let label: Label

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        feedback: Feedback = .none,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.feedback = feedback
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button(action: performAction) {
            label
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(background)
                .overlay(border)
                .contentShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(feedback != .none)
        .scaleEffect(scale)
        .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6), value: feedback)
    }
}

// MARK: - Helpers
private extension AnswerButton {
    func performAction() {
        guard feedback == .none else { return }
        action()
    }

    var background: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
            .fill(backgroundTint)
    }

    @ViewBuilder
    var border: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
            .strokeBorder(borderTint, lineWidth: feedback == .none ? 1 : 2)
    }

    var backgroundTint: Color {
        switch feedback {
        case .none:    DesignSystem.Color.cardBackground
        case .correct: DesignSystem.Color.success.opacity(0.18)
        case .wrong:   DesignSystem.Color.error.opacity(0.18)
        case .reveal:  DesignSystem.Color.success.opacity(0.1)
        }
    }

    var borderTint: Color {
        switch feedback {
        case .none:    DesignSystem.Color.dividerSubtle
        case .correct: DesignSystem.Color.success
        case .wrong:   DesignSystem.Color.error
        case .reveal:  DesignSystem.Color.success
        }
    }

    var scale: CGFloat {
        guard !reduceMotion else { return 1 }
        return switch feedback {
        case .correct: 1.02
        case .wrong:   0.98
        default:       1.0
        }
    }
}
