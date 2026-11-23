import SwiftUI

public struct QuizOptionButton: View {
    // MARK: - Properties
    public let text: String?
    public let flagCode: String?
    public let state: OptionState
    public let index: Int
    public let action: () -> Void

    // MARK: - Init
    public init(
        text: String? = nil,
        flagCode: String? = nil,
        state: OptionState,
        index: Int,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.flagCode = flagCode
        self.state = state
        self.index = index
        self.action = action
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var shakeOffset: CGFloat = 0

    // MARK: - Body
    public var body: some View {
        styledButton
            .buttonBorderShape(.capsule)
            .allowsHitTesting(state == .default)
            .disabled(state == .disabled)
            .offset(x: shakeOffset)
            .animation(.easeInOut(duration: 0.2), value: state)
            #if !os(tvOS)
            .keyboardShortcut(keyForIndex, modifiers: [])
            #endif
            .onChange(of: state) { _, newState in
                if newState == .incorrect, !reduceMotion {
                    Task { await shake() }
                }
            }
            .accessibilityLabel(accessibilityTitle)
            .accessibilityValue(accessibilityStateValue)
    }
}

// MARK: - Button
private extension QuizOptionButton {
    /// The system glass button, tinted green or red once the answer shows. Before iOS 26.1 the style takes no
    /// tint, so the same capsule of glass is drawn directly.
    @ViewBuilder
    var styledButton: some View {
        if #available(iOS 26.1, tvOS 26.1, *) {
            Button(action: action) { label }
                .buttonStyle(.glass(glass))
        } else {
            Button(action: action) {
                label
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .glassEffect(glass.interactive(), in: .capsule)
            }
            .buttonStyle(.plain)
        }
    }

    var label: some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.xxs)
    }

    var glass: Glass {
        guard let tint else { return .regular }
        return .regular.tint(tint)
    }
}

// MARK: - Accessibility
private extension QuizOptionButton {
    // A flag answer reads as "Option A", never the country, so VoiceOver doesn't give it away.
    var accessibilityTitle: Text {
        if let text {
            Text(text)
        } else {
            Text("Option \(optionLetter)")
        }
    }

    var accessibilityStateValue: Text {
        switch state {
        case .correct: Text("Correct")
        case .incorrect: Text("Incorrect")
        case .default, .disabled: Text("")
        }
    }

    var optionLetter: String {
        let letters = ["A", "B", "C", "D", "E", "F"]
        return index < letters.count ? letters[index] : ""
    }
}

// MARK: - Keyboard Shortcut
private extension QuizOptionButton {
    var keyForIndex: KeyEquivalent {
        switch index {
        case 0: "1"
        case 1: "2"
        case 2: "3"
        case 3: "4"
        default: "1"
        }
    }
}

// MARK: - OptionState
public extension QuizOptionButton {
    enum OptionState: Equatable {
        case `default`
        case correct
        case incorrect
        case disabled
    }
}

// MARK: - Subviews
private extension QuizOptionButton {
    @ViewBuilder
    var content: some View {
        if let flagCode {
            flagContent(flagCode)
        } else {
            textContent
        }
    }

    var textContent: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            letterBadge
            if let text {
                Text(text)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            stateIcon
        }
    }

    func flagContent(_ code: String) -> some View {
        ZStack {
            FlagView(countryCode: code, height: DesignSystem.Size.xl + 12)
                .frame(maxWidth: .infinity)
            stateIconOverlay
        }
    }

    var letterBadge: some View {
        Text(optionLetter)
            .font(DesignSystem.Font.footnote.weight(.black))
            .foregroundStyle(badgeTextColor)
            .frame(width: DesignSystem.Size.md, height: DesignSystem.Size.md)
            .background(badgeBackground, in: .circle)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    var stateIcon: some View {
        switch state {
        case .correct:
            Image(systemName: "checkmark.circle.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .transition(.scale.combined(with: .opacity))
        case .incorrect:
            Image(systemName: "xmark.circle.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .transition(.scale.combined(with: .opacity))
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    var stateIconOverlay: some View {
        switch state {
        case .correct:
            Image(systemName: "checkmark.circle.fill")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .shadow(color: DesignSystem.Color.success.opacity(DesignSystem.Opacity.heavy), radius: 8)
                .transition(.scale.combined(with: .opacity))
        case .incorrect:
            Image(systemName: "xmark.circle.fill")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .shadow(color: DesignSystem.Color.error.opacity(DesignSystem.Opacity.heavy), radius: 8)
                .transition(.scale.combined(with: .opacity))
        default:
            EmptyView()
        }
    }
}

// MARK: - Helpers
private extension QuizOptionButton {
    var tint: Color? {
        switch state {
        case .correct:   DesignSystem.Color.success
        case .incorrect: DesignSystem.Color.error
        default:         nil
        }
    }

    var textColor: Color {
        switch state {
        case .correct, .incorrect: DesignSystem.Color.onAccent
        case .disabled:            DesignSystem.Color.textTertiary
        default:                   DesignSystem.Color.textPrimary
        }
    }

    var badgeBackground: Color {
        switch state {
        case .correct:   DesignSystem.Color.success.opacity(DesignSystem.Opacity.half)
        case .incorrect: DesignSystem.Color.error.opacity(DesignSystem.Opacity.half)
        case .disabled:  DesignSystem.Color.cardBackground.opacity(DesignSystem.Opacity.half)
        default:         DesignSystem.Color.cardBackgroundHighlighted
        }
    }

    var badgeTextColor: Color {
        switch state {
        case .correct, .incorrect: DesignSystem.Color.onAccent
        case .disabled:            DesignSystem.Color.textTertiary
        default:                   DesignSystem.Color.textSecondary
        }
    }

    func shake() async {
        let step: Duration = .milliseconds(60)
        for _ in 0..<4 {
            withAnimation(.easeInOut(duration: 0.06)) { shakeOffset = 9 }
            try? await Task.sleep(for: step)
            withAnimation(.easeInOut(duration: 0.06)) { shakeOffset = -9 }
            try? await Task.sleep(for: step)
        }
        withAnimation(.easeInOut(duration: 0.06)) { shakeOffset = 0 }
    }
}
