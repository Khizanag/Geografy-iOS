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

    @State private var shakeOffset: CGFloat = 0

    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            content
                .frame(maxWidth: .infinity)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm + 2)
                .background { backgroundLayer }
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                .overlay {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .strokeBorder(borderColor, lineWidth: 1.5)
                }
        }
        .buttonStyle(PressButtonStyle())
        .disabled(state != .default)
        .shadow(color: glowColor, radius: glowRadius, y: 3)
        .offset(x: shakeOffset)
        .animation(.easeInOut(duration: 0.2), value: state)
        #if !os(tvOS)
        .keyboardShortcut(keyForIndex, modifiers: [])
        #endif
        .onChange(of: state) { _, newState in
            if newState == .incorrect {
                Task { await shake() }
            }
        }
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
        let letters = ["A", "B", "C", "D", "E", "F"]
        let letter = index < letters.count ? letters[index] : ""
        return Text(letter)
            .font(DesignSystem.Font.footnote.weight(.black))
            .foregroundStyle(badgeTextColor)
            .frame(width: DesignSystem.Size.md, height: DesignSystem.Size.md)
            .background(badgeBackground, in: RoundedRectangle(cornerRadius: 7))
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
                .shadow(color: DesignSystem.Color.success.opacity(0.8), radius: 8)
                .transition(.scale.combined(with: .opacity))
        case .incorrect:
            Image(systemName: "xmark.circle.fill")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .shadow(color: DesignSystem.Color.error.opacity(0.8), radius: 8)
                .transition(.scale.combined(with: .opacity))
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    var backgroundLayer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(overlayColor)
        }
    }
}

// MARK: - Helpers
private extension QuizOptionButton {
    var overlayColor: Color {
        switch state {
        case .default:      .clear
        case .correct:      DesignSystem.Color.success.opacity(0.30)
        case .incorrect:    DesignSystem.Color.error.opacity(0.28)
        case .disabled:     .primary.opacity(0.08)
        }
    }

    var borderColor: Color {
        switch state {
        case .default:      .primary.opacity(0.08)
        case .correct:      DesignSystem.Color.success.opacity(0.70)
        case .incorrect:    DesignSystem.Color.error.opacity(0.60)
        case .disabled:     .clear
        }
    }

    var glowColor: Color {
        switch state {
        case .correct:   DesignSystem.Color.success.opacity(0.45)
        case .incorrect: DesignSystem.Color.error.opacity(0.35)
        default:         .clear
        }
    }

    var glowRadius: CGFloat {
        switch state {
        case .correct:   14
        case .incorrect: 10
        default:         0
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
        case .correct:   DesignSystem.Color.success.opacity(0.5)
        case .incorrect: DesignSystem.Color.error.opacity(0.4)
        case .disabled:  DesignSystem.Color.cardBackground.opacity(0.5)
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
