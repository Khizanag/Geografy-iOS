import Geografy_Core_Service
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

struct QuizSetupScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let countryDataService: CountryDataService

    @State private var selectedType: QuizType = .flagQuiz
    @State private var selectedRegion: QuizRegion = .world
    @State private var selectedDifficulty: QuizDifficulty = .easy
    @State private var selectedCount = 10
    @State private var showQuiz = false
    @State private var showMultiplayer = false

    var body: some View {
        ScrollView {
            VStack(spacing: 48) {
                quizTypeSection

                difficultySection

                settingsSection

                startButton
            }
            .padding(.horizontal, 80)
            .padding(.vertical, 40)
        }
        .background { AmbientBlobsView(.tv) }
        .navigationTitle("Quiz")
        .fullScreenCover(isPresented: $showQuiz) {
            QuizSessionScreen(
                countryDataService: countryDataService,
                quizType: selectedType,
                region: selectedRegion,
                difficulty: selectedDifficulty,
                questionCount: selectedCount,
            )
        }
        .fullScreenCover(isPresented: $showMultiplayer) {
            MultiplayerQuizScreen(
                countryDataService: countryDataService,
                quizType: selectedType,
                region: selectedRegion,
                difficulty: selectedDifficulty,
                questionCount: selectedCount,
            )
        }
    }
}

// MARK: - Quiz Type
private extension QuizSetupScreen {
    var quizTypeSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose Your Quiz")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .focusable(false)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20),
                ],
                spacing: 20
            ) {
                ForEach(QuizType.allCases) { type in
                    quizTypeCard(type)
                }
            }
        }
    }

    func quizTypeCard(_ type: QuizType) -> some View {
        let isSelected = selectedType == type
        let color = quizTypeColor(type)

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedType = type
            }
        } label: {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(isSelected ? 0.3 : 0.15))
                        .frame(width: 64, height: 64)

                    Image(systemName: type.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(color)
                }

                Text(type.displayName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Text(type.description)
                    .font(.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 44)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(DesignSystem.Color.cardBackground.opacity(isSelected ? 0.8 : 0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? color : .clear, lineWidth: 3)
            )
        }
        .buttonStyle(CardButtonStyle())
        .accessibilityLabel("\(type.displayName). \(type.description)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    func quizTypeColor(_ type: QuizType) -> Color {
        switch type {
        case .flagQuiz: DesignSystem.Color.orange
        case .capitalQuiz: DesignSystem.Color.blue
        case .reverseFlag: DesignSystem.Color.purple
        case .reverseCapital: DesignSystem.Color.indigo
        case .worldRankings: DesignSystem.Color.success
        case .nationalSymbols: DesignSystem.Color.warning
        }
    }
}

// MARK: - Difficulty
private extension QuizSetupScreen {
    var difficultySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Difficulty")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .focusable(false)

            HStack(spacing: 20) {
                ForEach(QuizDifficulty.allCases) { difficulty in
                    difficultyCard(difficulty)
                }
            }
        }
    }

    func difficultyCard(_ difficulty: QuizDifficulty) -> some View {
        let isSelected = selectedDifficulty == difficulty
        let color = difficultyColor(difficulty)

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDifficulty = difficulty
            }
        } label: {
            VStack(spacing: 14) {
                Image(systemName: difficulty.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(color)

                Text(difficulty.displayName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Text(difficulty.subtitle)
                    .font(.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(DesignSystem.Color.cardBackground.opacity(isSelected ? 0.8 : 0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? color : .clear, lineWidth: 3)
            )
        }
        .buttonStyle(CardButtonStyle())
        .accessibilityLabel("\(difficulty.displayName). \(difficulty.subtitle)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    func difficultyColor(_ difficulty: QuizDifficulty) -> Color {
        switch difficulty {
        case .easy: DesignSystem.Color.success
        case .medium: DesignSystem.Color.warning
        case .hard: DesignSystem.Color.error
        }
    }
}

// MARK: - Settings
private extension QuizSetupScreen {
    var settingsSection: some View {
        HStack(spacing: 24) {
            settingsCard(title: "Region", icon: "globe") {
                Picker("Region", selection: $selectedRegion) {
                    ForEach(QuizRegion.allCases) { region in
                        Text(region.displayName)
                            .tag(region)
                    }
                }
                .pickerStyle(.menu)
            }

            settingsCard(title: "Questions", icon: "number") {
                Picker("Count", selection: $selectedCount) {
                    ForEach([5, 10, 15, 20, 30], id: \.self) { count in
                        Text("\(count)")
                            .tag(count)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }

    func settingsCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.textSecondary)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(28)
        .background(
            DesignSystem.Color.cardBackground.opacity(0.4),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }
}

// MARK: - Start Buttons
private extension QuizSetupScreen {
    var startButton: some View {
        HStack(spacing: 32) {
            Button {
                showQuiz = true
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 28))

                    Text("Solo")
                        .font(.system(size: 28, weight: .bold))
                }
                .frame(maxWidth: 300)
                .padding(.vertical, 20)
            }
            .buttonStyle(.bordered)

            Button {
                showMultiplayer = true
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 28))

                    Text("Multiplayer")
                        .font(.system(size: 28, weight: .bold))
                }
                .frame(maxWidth: 300)
                .padding(.vertical, 20)
            }
            .buttonStyle(.bordered)
        }
    }
}
