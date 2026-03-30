import SwiftUI

struct SpellingBeeGuideSheet: View {
    @State private var animating = false

    private let illustrations = SpellingBeeIllustration.allCases

    var body: some View {
        GuideSheet(pages: SpellingBeeGuide.pages) { index in
            illustrationView(for: illustrations[index])
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animating = true
            }
        }
    }
}

// MARK: - Illustrations
private extension SpellingBeeGuideSheet {
    @ViewBuilder
    func illustrationView(for type: SpellingBeeIllustration) -> some View {
        switch type {
        case .flagAndType: flagAndTypeIllustration
        case .letterFeedback: letterFeedbackIllustration
        case .hints: hintsIllustration
        case .scoring: scoringIllustration
        }
    }

    var flagAndTypeIllustration: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("🇫🇷")
                .font(DesignSystem.Font.display)
                .scaleEffect(animating ? 1.05 : 0.95)
            HStack(spacing: 4) {
                ForEach(Array("FRANCE".enumerated()), id: \.offset) { index, letter in
                    Text(String(letter))
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                        .frame(width: 32, height: 36)
                        .background(
                            DesignSystem.Color.success,
                            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        )
                        .opacity(animating ? 1 : (Double(index) / 6.0))
                }
            }
        }
        .frame(height: 160)
    }

    var letterFeedbackIllustration: some View {
        HStack(spacing: 4) {
            letterMock("B", correct: true)
            letterMock("R", correct: true)
            letterMock("A", correct: true)
            letterMock("S", correct: false)
            letterMock("_", correct: false, empty: true)
            letterMock("_", correct: false, empty: true)
        }
        .frame(height: 160)
    }

    var hintsIllustration: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            hintMock(icon: "textformat", text: "First letter: K", used: true)
            hintMock(icon: "building.columns", text: "Capital: Tokyo", used: true)
            hintMock(icon: "person.2", text: "Population", used: false)
        }
        .frame(height: 160, alignment: .center)
    }

    var scoringIllustration: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            scoreMock(value: "30", label: "No hints", filled: true)
            scoreMock(value: "20", label: "1 hint", filled: false)
            scoreMock(value: "10", label: "2+ hints", filled: false)
        }
        .scaleEffect(animating ? 1.0 : 0.95)
        .frame(height: 160, alignment: .center)
    }
}

// MARK: - Illustration Helpers
private extension SpellingBeeGuideSheet {
    func letterMock(_ letter: String, correct: Bool, empty: Bool = false) -> some View {
        Text(empty ? "" : letter)
            .font(DesignSystem.Font.headline)
            .fontWeight(.bold)
            .foregroundStyle(empty ? .clear : DesignSystem.Color.onAccent)
            .frame(width: 32, height: 36)
            .background(
                empty
                    ? DesignSystem.Color.cardBackgroundHighlighted
                    : (correct ? DesignSystem.Color.success : DesignSystem.Color.error),
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
            )
    }

    func hintMock(icon: String, text: String, used: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(used ? DesignSystem.Color.accent : DesignSystem.Color.textTertiary)
            Text(text)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(used ? DesignSystem.Color.textPrimary : DesignSystem.Color.textTertiary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            used ? DesignSystem.Color.accent.opacity(0.12) : DesignSystem.Color.cardBackground,
            in: Capsule()
        )
    }

    func scoreMock(value: String, label: String, filled: Bool) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Text(value)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(filled ? DesignSystem.Color.accent : DesignSystem.Color.textTertiary)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            filled ? DesignSystem.Color.accent.opacity(0.12) : DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}
