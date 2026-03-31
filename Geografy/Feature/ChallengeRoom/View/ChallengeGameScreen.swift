import SwiftUI
import GeografyDesign

struct ChallengeGameScreen: View {
    @Environment(Coordinator.self) private var coordinator
    @Environment(HapticsService.self) private var hapticsService

    @State private var room: ChallengeRoom
    @State private var showingPassScreen = true
    @State private var selectedOptionIndex: Int?
    @State private var showingResult = false
    @State private var wasCorrect = false

    private let challengeRoomService: ChallengeRoomService

    init(room: ChallengeRoom, challengeRoomService: ChallengeRoomService) {
        _room = State(initialValue: room)
        self.challengeRoomService = challengeRoomService
    }

    var body: some View {
        Group {
            if showingPassScreen {
                passScreen
            } else {
                questionScreen
            }
        }
        .background { AmbientBlobsView(.quiz) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CircleCloseButton { coordinator.dismiss() }
            }
        }
    }
}

// MARK: - Pass Screen
private extension ChallengeGameScreen {
    var passScreen: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(DesignSystem.Color.orange.opacity(0.15))
                    .frame(width: 96, height: 96)

                Image(systemName: "hand.point.right.fill")
                    .font(DesignSystem.Font.displayXXS)
                    .foregroundStyle(DesignSystem.Color.orange)
            }

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Pass to")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)

                Text(room.currentPlayerName)
                    .font(DesignSystem.Font.title)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Text("Round \(String(room.roundNumber)) of \(String(room.totalRounds))")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)

                scoreRow
            }

            Spacer()

            GlassButton("I'm Ready", systemImage: "play.fill", fullWidth: true) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingPassScreen = false
                    selectedOptionIndex = nil
                    showingResult = false
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.lg)
        }
    }

    var scoreRow: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            scoreChip(name: room.player1Name, score: room.player1Score, isActive: room.currentPlayerIndex == 0)

            Text("vs")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)

            scoreChip(name: room.player2Name, score: room.player2Score, isActive: room.currentPlayerIndex == 1)
        }
        .padding(.top, DesignSystem.Spacing.sm)
    }

    func scoreChip(name: String, score: Int, isActive: Bool) -> some View {
        VStack(spacing: 2) {
            Text("\(score)")
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(isActive ? DesignSystem.Color.accent : DesignSystem.Color.textSecondary)
                .contentTransition(.numericText())

            Text(name)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
    }
}

// MARK: - Question Screen
private extension ChallengeGameScreen {
    var questionScreen: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            SessionProgressView(
                progress: progressFraction,
                current: (room.roundNumber - 1) * 2 + room.currentPlayerIndex + 1,
                total: room.totalRounds * 2
            )

            playerBadge

            questionPrompt

            optionsList

            Spacer(minLength: 0)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.sm)
        .safeAreaInset(edge: .bottom) {
            if showingResult {
                nextButton
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.md)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    var playerBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Circle()
                .fill(room.currentPlayerIndex == 0 ? DesignSystem.Color.blue : DesignSystem.Color.orange)
                .frame(width: 8, height: 8)

            Text(room.currentPlayerName)
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Spacer()

            Text("\(room.player1Score) – \(room.player2Score)")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    @ViewBuilder
    var questionPrompt: some View {
        if let question = room.currentQuestion {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(question.question)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.lg)
        }
    }

    @ViewBuilder
    var optionsList: some View {
        if let question = room.currentQuestion {
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(question.options.indices, id: \.self) { index in
                    QuizOptionButton(
                        text: question.options[index],
                        flagCode: nil,
                        state: optionState(index: index, correctIndex: question.correctIndex),
                        index: index
                    ) {
                        selectOption(index, correctIndex: question.correctIndex)
                    }
                }
            }
        }
    }

    var nextButton: some View {
        GlassButton(
            isLastTurnInGame ? "See Results" : "Next",
            systemImage: isLastTurnInGame ? "trophy.fill" : "arrow.right",
            fullWidth: true
        ) {
            advanceToNext()
        }
    }
}

// MARK: - Actions
private extension ChallengeGameScreen {
    var progressFraction: CGFloat {
        guard room.totalRounds > 0 else { return 0 }
        let totalTurns = CGFloat(room.totalRounds * 2)
        let completedTurns = CGFloat((room.roundNumber - 1) * 2 + room.currentPlayerIndex)
        return completedTurns / totalTurns
    }

    var isLastTurnInGame: Bool {
        room.roundNumber == room.totalRounds && room.currentPlayerIndex == 1
    }

    func optionState(index: Int, correctIndex: Int) -> QuizOptionButton.OptionState {
        guard showingResult else { return .default }
        if index == correctIndex { return .correct }
        if selectedOptionIndex == index { return .incorrect }
        return .disabled
    }

    func selectOption(_ index: Int, correctIndex: Int) {
        guard !showingResult else { return }
        selectedOptionIndex = index
        wasCorrect = index == correctIndex
        challengeRoomService.score(room: &room, wasCorrect: wasCorrect)
        hapticsService.notification(wasCorrect ? .success : .error)
        withAnimation(.easeInOut(duration: 0.25)) {
            showingResult = true
        }
    }

    func advanceToNext() {
        challengeRoomService.advance(room: &room)
        if room.isFinished {
            coordinator.push(.challengeResult(room))
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingPassScreen = true
                showingResult = false
                selectedOptionIndex = nil
            }
        }
    }
}
