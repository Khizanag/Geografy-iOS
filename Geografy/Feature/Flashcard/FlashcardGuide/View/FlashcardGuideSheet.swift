import SwiftUI

struct FlashcardGuideSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var currentPage = 0
    @State private var animating = false

    private let pages = FlashcardGuide.pages

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

private extension FlashcardGuideSheet {
    func guidePage(_ page: FlashcardGuidePage) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                animatedIllustration(for: page.illustration)
                pageText(page)
                if !page.steps.isEmpty {
                    stepsSection(page.steps)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }

    func pageText(_ page: FlashcardGuidePage) -> some View {
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

    func stepsSection(_ steps: [FlashcardGuideStep]) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(steps) { step in
                stepCard(step)
            }
        }
    }

    func stepCard(_ step: FlashcardGuideStep) -> some View {
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

// MARK: - Animated Illustrations

private extension FlashcardGuideSheet {
    @ViewBuilder
    func animatedIllustration(for type: FlashcardGuidePage.Illustration) -> some View {
        switch type {
        case .tapToFlip:
            tapToFlipIllustration
        case .swipeToRate:
            swipeToRateIllustration
        case .ratingButtons:
            ratingButtonsIllustration
        case .spacedRepetition:
            spacedRepetitionIllustration
        case .proTips:
            proTipsIllustration
        }
    }

    var tapToFlipIllustration: some View {
        ZStack {
            cardMock(front: true)
                .rotation3DEffect(
                    .degrees(animating ? 0 : 8),
                    axis: (x: 0, y: 1, z: 0)
                )

            handIcon
                .offset(y: animating ? 10 : -10)
        }
        .frame(height: 200)
    }

    var swipeToRateIllustration: some View {
        ZStack {
            cardMock(front: false)
                .offset(x: animating ? 40 : -40)
                .rotationEffect(.degrees(animating ? 4 : -4))

            HStack(spacing: DesignSystem.Spacing.xxl) {
                swipeArrow(direction: .left, color: DesignSystem.Color.error)
                swipeArrow(direction: .right, color: DesignSystem.Color.success)
            }
        }
        .frame(height: 200)
    }

    var ratingButtonsIllustration: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ratingMock(label: "Wrong", color: DesignSystem.Color.error, icon: "xmark.circle.fill")
            ratingMock(label: "Struggled", color: DesignSystem.Color.orange, icon: "exclamationmark.triangle.fill")
            ratingMock(label: "Correct", color: DesignSystem.Color.accent, icon: "checkmark.circle.fill")
            ratingMock(label: "Knew It", color: DesignSystem.Color.success, icon: "bolt.circle.fill")
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .frame(height: 200, alignment: .center)
    }

    var spacedRepetitionIllustration: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(Array(["1d", "3d", "7d", "14d"].enumerated()), id: \.offset) { index, label in
                VStack(spacing: DesignSystem.Spacing.xxs) {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .fill(DesignSystem.Color.accent.opacity(0.15 + Double(index) * 0.2))
                        .frame(width: 50, height: CGFloat(40 + index * 25))
                    Text(label)
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                .scaleEffect(animating ? 1.0 : 0.9)
                .animation(
                    .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                    value: animating
                )
            }
        }
        .frame(height: 200, alignment: .center)
    }

    var proTipsIllustration: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.08))
                .frame(width: 160, height: 160)
                .scaleEffect(animating ? 1.1 : 0.9)

            Image(systemName: "lightbulb.fill")
                .font(.system(size: 60))
                .foregroundStyle(DesignSystem.Color.accent)
                .scaleEffect(animating ? 1.05 : 0.95)
        }
        .frame(height: 200)
    }
}

// MARK: - Illustration Helpers

private extension FlashcardGuideSheet {
    func cardMock(front: Bool) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(DesignSystem.Color.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .strokeBorder(DesignSystem.Color.cardBackgroundHighlighted, lineWidth: 1)
            )
            .overlay {
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text(front ? "🇵🇹" : "Lisbon")
                        .font(front ? .system(size: 40) : DesignSystem.Font.title2)
                    Text(front ? "What is the capital?" : "Tap to flip")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
            }
            .frame(width: 160, height: 120)
    }

    var handIcon: some View {
        Image(systemName: "hand.tap.fill")
            .font(.system(size: 28))
            .foregroundStyle(DesignSystem.Color.accent.opacity(0.6))
            .offset(x: 50, y: 40)
    }

    enum SwipeDirection { case left, right }

    func swipeArrow(direction: SwipeDirection, color: Color) -> some View {
        Image(systemName: direction == .left ? "arrow.left.circle.fill" : "arrow.right.circle.fill")
            .font(.system(size: 32))
            .foregroundStyle(color.opacity(animating ? 0.8 : 0.3))
    }

    func ratingMock(label: String, color: Color, icon: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.subheadline)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(color)
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(color.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Page Indicator

private extension FlashcardGuideSheet {
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
