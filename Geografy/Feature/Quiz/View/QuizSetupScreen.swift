import SwiftUI

struct QuizSetupScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionService.self) private var subscriptionService

    @AppStorage("quiz_selectedType") private var selectedType: QuizType = .flagQuiz
    @AppStorage("quiz_selectedRegion") private var selectedRegion: QuizRegion = .world
    @AppStorage("quiz_selectedDifficulty") private var selectedDifficulty: QuizDifficulty = .easy
    @AppStorage("quiz_selectedCount") private var selectedCount: QuestionCount = .ten
    @State private var showQuizSession = false
    @State private var showPaywall = false
    @State private var emojiBounce: [QuizType: Int] = [:]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                    quizTypeSection
                    regionRow
                    difficultySection
                    questionCountRow
                }
                .padding(.vertical, DesignSystem.Spacing.md)
            }
            .safeAreaInset(edge: .bottom) {
                startButton
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Color.background)
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showQuizSession) {
                QuizSessionScreen(configuration: makeConfiguration())
            }
            .sheet(isPresented: $showPaywall) {
                PaywallScreen()
            }
        }
    }
}

// MARK: - Quiz Type Section

private extension QuizSetupScreen {
    var quizTypeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Quiz Type")

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 140), spacing: DesignSystem.Spacing.sm)],
                spacing: DesignSystem.Spacing.sm
            ) {
                ForEach(QuizType.allCases) { type in
                    quizTypeCard(type)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    func quizTypeCard(_ type: QuizType) -> some View {
        let isSelected = selectedType == type
        let colors = quizTypeGradient(type)
        let isLocked = type.isPremium && !subscriptionService.isPremium

        return Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            if type.isPremium, !subscriptionService.isPremium {
                showPaywall = true
            } else {
                selectedType = type
                emojiBounce[type, default: 0] += 1
            }
        } label: {
            quizTypeCardLabel(type: type, isSelected: isSelected, colors: colors, isLocked: isLocked)
        }
        .buttonStyle(.plain)
    }

    func quizTypeCardLabel(
        type: QuizType,
        isSelected: Bool,
        colors: (Color, Color),
        isLocked: Bool
    ) -> some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(colors: [colors.0, colors.1], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: type.icon)
                .font(DesignSystem.IconSize.hero)
                .foregroundStyle(.white.opacity(0.10))
                .offset(x: 18, y: -12)
                .clipped()
            quizTypeCardInfo(type: type)
            if isLocked { quizTypeLockOverlay }
        }
        .frame(minHeight: 130)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .strokeBorder(.white.opacity(isSelected ? 0.55 : 0), lineWidth: 2)
        )
        .shadow(color: colors.0.opacity(isSelected ? 0.55 : 0.25), radius: isSelected ? 16 : 8, y: 5)
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    func quizTypeCardInfo(type: QuizType) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(type.emoji)
                .font(DesignSystem.Font.title)
                .keyframeAnimator(
                    initialValue: EmojiAnimation(),
                    trigger: emojiBounce[type, default: 0]
                ) { content, value in
                    content
                        .scaleEffect(value.scale)
                        .rotationEffect(.degrees(value.rotation))
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        SpringKeyframe(1.5, duration: 0.15, spring: .bouncy(duration: 0.2, extraBounce: 0.3))
                        SpringKeyframe(1.0, duration: 0.35, spring: .bouncy(duration: 0.3, extraBounce: 0.1))
                    }
                    KeyframeTrack(\.rotation) {
                        SpringKeyframe(12.0, duration: 0.12, spring: .bouncy)
                        SpringKeyframe(-8.0, duration: 0.12, spring: .bouncy)
                        SpringKeyframe(0.0, duration: 0.2, spring: .bouncy)
                    }
                }
            Text(type.displayName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .lineLimit(1)
            Text(type.description)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(.white.opacity(0.75))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(DesignSystem.Spacing.sm)
    }

    var quizTypeLockOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(.black.opacity(0.45))
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Label("Premium", systemImage: "lock.fill")
                        .font(DesignSystem.Font.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                        .padding(.horizontal, DesignSystem.Spacing.xs)
                        .padding(.vertical, DesignSystem.Spacing.xxs)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(DesignSystem.Spacing.xs)
                }
            }
        }
    }

    func quizTypeGradient(_ type: QuizType) -> (Color, Color) {
        switch type {
        case .flagQuiz:         (Color(hex: "C62828"), Color(hex: "E53935"))
        case .capitalQuiz:      (Color(hex: "1565C0"), Color(hex: "1E88E5"))
        case .reverseFlag:      (Color(hex: "6A1B9A"), Color(hex: "8E24AA"))
        case .reverseCapital:   (Color(hex: "00695C"), Color(hex: "00897B"))
        case .populationOrder:  (Color(hex: "E65100"), Color(hex: "FB8C00"))
        case .areaOrder:        (Color(hex: "2E7D32"), Color(hex: "43A047"))
        }
    }
}

// MARK: - Region Row

private extension QuizSetupScreen {
    var regionRow: some View {
        pickerRow("Region", selection: $selectedRegion) { region in
            Text(region.displayName).tag(region)
        }
    }
}

// MARK: - Difficulty Section

private extension QuizSetupScreen {
    var difficultySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Difficulty")

            Picker("Difficulty", selection: $selectedDifficulty) {
                ForEach(QuizDifficulty.allCases) { difficulty in
                    Text(difficulty.displayName).tag(difficulty)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, DesignSystem.Spacing.md)

            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: selectedDifficulty.icon)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text(selectedDifficulty.subtitle)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .animation(.easeInOut(duration: 0.2), value: selectedDifficulty)
        }
    }
}

// MARK: - Question Count Row

private extension QuizSetupScreen {
    var questionCountRow: some View {
        pickerRow("Questions", selection: $selectedCount) { count in
            Text(count.displayName).tag(count)
        }
    }
}

// MARK: - Start Button

private extension QuizSetupScreen {
    var startButton: some View {
        Button {
            if selectedType.isPremium, !subscriptionService.isPremium {
                showPaywall = true
            } else {
                showQuizSession = true
            }
        } label: {
            Label("Start Quiz", systemImage: "play.fill")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xxs)
        }
        .buttonStyle(.glass)
    }
}

// MARK: - Helpers

private extension QuizSetupScreen {
    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func pickerRow<T: Hashable, Content: View>(
        _ title: String,
        selection: Binding<T>,
        @ViewBuilder content: @escaping (T) -> Content
    ) -> some View where T: CaseIterable, T: Identifiable, T.AllCases: RandomAccessCollection {
        HStack {
            Text(title)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Spacer()

            Picker(title, selection: selection) {
                ForEach(Array(T.allCases)) { item in
                    content(item)
                }
            }
            .pickerStyle(.menu)
            .tint(DesignSystem.Color.accent)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func makeConfiguration() -> QuizConfiguration {
        QuizConfiguration(
            type: selectedType,
            region: selectedRegion,
            difficulty: selectedDifficulty,
            questionCount: selectedCount,
        )
    }
}

// MARK: - Emoji Animation

private struct EmojiAnimation {
    var scale: CGFloat = 1.0
    var rotation: Double = 0.0
}
