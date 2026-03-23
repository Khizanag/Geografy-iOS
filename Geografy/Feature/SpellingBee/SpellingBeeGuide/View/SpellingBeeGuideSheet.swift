import SwiftUI

struct SpellingBeeGuideSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var currentPage = 0
    @State private var animating = false

    private let pages = SpellingBeeGuide.pages

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        guidePage(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageIndicatorAndButton
            }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CircleCloseButton()
                }
            }
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2).repeatForever(autoreverses: true)
                ) {
                    animating = true
                }
            }
        }
    }
}

// MARK: - Page Content

private extension SpellingBeeGuideSheet {
    func guidePage(_ page: SpellingBeeGuidePage) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                animatedIllustration(for: page.illustration)
                pageText(page)
                stepsSection(page.steps)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }

    func pageText(_ page: SpellingBeeGuidePage) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(page.title)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
            Text(page.subtitle)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func stepsSection(_ steps: [SpellingBeeGuideStep]) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(steps) { step in
                stepCard(step)
            }
        }
    }

    func stepCard(_ step: SpellingBeeGuideStep) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: step.icon)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(step.title)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(step.description)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}

// MARK: - Illustrations

private extension SpellingBeeGuideSheet {
    @ViewBuilder
    func animatedIllustration(for type: SpellingBeeGuidePage.Illustration) -> some View {
        switch type {
        case .flagAndType:
            flagAndTypeIllustration
        case .letterFeedback:
            letterFeedbackIllustration
        case .hints:
            hintsIllustration
        case .scoring:
            scoringIllustration
        }
    }

    var flagAndTypeIllustration: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("🇫🇷")
                .font(.system(size: 60))
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

// MARK: - Page Indicator

private extension SpellingBeeGuideSheet {
    var pageIndicatorAndButton: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(
                            index == currentPage
                                ? DesignSystem.Color.accent
                                : DesignSystem.Color.cardBackgroundHighlighted
                        )
                        .frame(width: index == currentPage ? 20 : 8, height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                }
            }

            if currentPage == pages.count - 1 {
                GlassButton("Got it!", systemImage: "checkmark", fullWidth: true) {
                    dismiss()
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.vertical, DesignSystem.Spacing.md)
        .animation(.easeInOut(duration: 0.25), value: currentPage)
    }
}
