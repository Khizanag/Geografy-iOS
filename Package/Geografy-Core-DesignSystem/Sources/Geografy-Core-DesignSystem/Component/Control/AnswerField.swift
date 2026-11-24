import SwiftUI

/// The one text field for typed answers: a Liquid Glass capsule with an optional leading symbol,
/// a clear button while typing, and a send button when the screen submits.
/// Feedback rings the field green or red, and a wrong answer shakes it.
public struct AnswerField: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast

    @ScaledMetric(relativeTo: .body) private var minHeight = TextFieldMetrics.minHeight
    @ScaledMetric(relativeTo: .body) private var sendDiameter: CGFloat = 36

    @State private var shakeCount = 0

    @Binding private var text: String

    private let placeholder: String
    private let isFocused: FocusState<Bool>.Binding
    private let systemImage: String?
    private let color: Color
    private let feedback: Feedback
    private let message: String?
    private let capitalization: TextInputAutocapitalization
    private let showsSendButton: Bool
    private let onSubmit: (() -> Void)?

    public enum Feedback: Equatable, Sendable {
        case none
        case correct
        case incorrect
    }

    // MARK: - Init
    /// - Parameters:
    ///   - color: The screen's game color, used for the leading symbol and the send button.
    ///   - message: A short line under the field, colored by `feedback`.
    ///   - showsSendButton: Hide it on screens that check every keystroke and only use Return.
    ///   - onSubmit: Called from Return or the send button, never with blank text.
    public init(
        _ placeholder: String,
        text: Binding<String>,
        isFocused: FocusState<Bool>.Binding,
        systemImage: String? = nil,
        color: Color = DesignSystem.Color.blue,
        feedback: Feedback = .none,
        message: String? = nil,
        capitalization: TextInputAutocapitalization = .words,
        showsSendButton: Bool = true,
        onSubmit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.isFocused = isFocused
        self.systemImage = systemImage
        self.color = color
        self.feedback = feedback
        self.message = message
        self.capitalization = capitalization
        self.showsSendButton = showsSendButton
        self.onSubmit = onSubmit
    }

    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            field
            if let message {
                messageLabel(message)
            }
        }
        .animation(reduceMotion ? nil : .snappy(duration: 0.25), value: feedback)
        .animation(reduceMotion ? nil : .snappy(duration: 0.25), value: message)
        .onChange(of: feedback) { _, newValue in
            if newValue == .incorrect, !reduceMotion {
                shakeCount += 1
            }
        }
    }
}

// MARK: - Subviews
private extension AnswerField {
    var field: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(color)
                    .accessibilityHidden(true)
            }
            TextField(placeholder, text: $text)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(capitalization)
                .submitLabel(showsSendButton ? .send : .done)
                .focused(isFocused)
                .onSubmit(submit)
            trailingContent
        }
        .padding(.leading, DesignSystem.Spacing.md)
        .padding(.trailing, DesignSystem.Spacing.xs)
        .frame(minHeight: minHeight)
        .glassEffect(.regular, in: .capsule)
        .overlay {
            Capsule()
                .strokeBorder(ringColor, lineWidth: feedback == .none ? 1 : 2)
        }
        .keyframeAnimator(initialValue: CGFloat.zero, trigger: shakeCount) { content, offset in
            content.offset(x: offset)
        } keyframes: { _ in
            KeyframeTrack {
                LinearKeyframe(-10, duration: 0.06)
                LinearKeyframe(10, duration: 0.08)
                LinearKeyframe(-6, duration: 0.08)
                LinearKeyframe(6, duration: 0.08)
                LinearKeyframe(0, duration: 0.06)
            }
        }
    }

    @ViewBuilder
    var trailingContent: some View {
        switch feedback {
        case .correct, .incorrect:
            Image(systemName: feedback == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(feedbackColor)
                .frame(width: sendDiameter, height: sendDiameter)
                .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                .accessibilityLabel(feedback == .correct ? "Correct" : "Incorrect")
        case .none:
            if !text.isEmpty {
                clearButton
            }
            if showsSendButton, onSubmit != nil {
                sendButton
            }
        }
    }

    var clearButton: some View {
        Button {
            text = ""
            isFocused.wrappedValue = true
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .frame(minWidth: DesignSystem.Size.xl, minHeight: DesignSystem.Size.xl)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Clear text")
    }

    var sendButton: some View {
        Button(action: submit) {
            Image(systemName: "arrow.up")
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(isBlank ? DesignSystem.Color.textTertiary : DesignSystem.Color.onAccent)
                .frame(width: sendDiameter, height: sendDiameter)
                .background(isBlank ? DesignSystem.Color.cardBackgroundHighlighted : color, in: .circle)
                .contentShape(.circle)
        }
        .buttonStyle(PressButtonStyle())
        .disabled(isBlank)
        .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: isBlank)
        .accessibilityLabel("Submit")
    }

    func messageLabel(_ message: String) -> some View {
        Text(message)
            .font(DesignSystem.Font.footnote)
            .fontWeight(.medium)
            .foregroundStyle(feedback == .none ? DesignSystem.Color.textSecondary : feedbackColor)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .transition(.opacity)
            .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Actions
private extension AnswerField {
    func submit() {
        guard !isBlank else {
            isFocused.wrappedValue = true
            return
        }
        onSubmit?()
    }
}

// MARK: - Helpers
private extension AnswerField {
    var isBlank: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var feedbackColor: Color {
        feedback == .correct ? DesignSystem.Color.success : DesignSystem.Color.error
    }

    var ringColor: Color {
        switch feedback {
        case .correct, .incorrect: feedbackColor
        case .none: contrast == .increased ? DesignSystem.Color.textTertiary : .clear
        }
    }
}
