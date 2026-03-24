import SwiftUI

struct ChallengeSplitScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService

    @State private var coordinator = TabCoordinator()
    @State private var room: ChallengeRoom
    @State private var player1Answer: Int?
    @State private var player2Answer: Int?
    @State private var currentRound = 1
    @State private var showFeedback = false

    private let challengeRoomService: ChallengeRoomService

    init(room: ChallengeRoom, challengeRoomService: ChallengeRoomService) {
        self._room = State(initialValue: room)
        self.challengeRoomService = challengeRoomService
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            splitContent
                .background(DesignSystem.Color.background.ignoresSafeArea())
                .navigationBarHidden(true)
                .navigationDestination(for: ChallengeRoom.self) { finishedRoom in
                    ChallengeResultScreen(room: finishedRoom) { dismiss() }
                        .navigationTitle("Results")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden()
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                CircleCloseButton { dismiss() }
                            }
                        }
                }
        }
        .environment(coordinator)
    }
}

// MARK: - Split Content

private extension ChallengeSplitScreen {
    var splitContent: some View {
        VStack(spacing: 0) {
            playerHalf(
                playerIndex: 1,
                question: player2Question,
                selectedAnswer: player2Answer,
                onSelect: { selectAnswer(playerIndex: 1, optionIndex: $0) }
            )
            .rotationEffect(.degrees(180))

            centerBar

            playerHalf(
                playerIndex: 0,
                question: player1Question,
                selectedAnswer: player1Answer,
                onSelect: { selectAnswer(playerIndex: 0, optionIndex: $0) }
            )
        }
    }

    var centerBar: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Circle()
                    .fill(DesignSystem.Color.blue)
                    .frame(width: 6, height: 6)
                Text("\(room.player1Name): \(room.player1Score)")
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.blue)
            }

            Spacer()

            SessionProgressBar(progress: progressFraction)
                .frame(maxWidth: 120)

            Text("\(String(currentRound))/\(String(room.totalRounds))")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)

            Spacer()

            HStack(spacing: DesignSystem.Spacing.xxs) {
                Text("\(room.player2Name): \(room.player2Score)")
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.orange)
                Circle()
                    .fill(DesignSystem.Color.orange)
                    .frame(width: 6, height: 6)
            }

            CircleCloseButton { dismiss() }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(DesignSystem.Color.cardBackground)
    }

    func playerHalf(
        playerIndex: Int,
        question: ChallengeQuestion?,
        selectedAnswer: Int?,
        onSelect: @escaping (Int) -> Void
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            HStack {
                Text(playerIndex == 0 ? room.player1Name : room.player2Name)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        playerIndex == 0 ? DesignSystem.Color.blue : DesignSystem.Color.orange
                    )

                Spacer()

                if let question {
                    Text(question.category.uppercased())
                        .font(DesignSystem.Font.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.accent)
                        .kerning(0.6)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)

            if let question {
                Text(question.question)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, DesignSystem.Spacing.md)

                Spacer()

                VStack(spacing: DesignSystem.Spacing.xxs) {
                    ForEach(question.options.indices, id: \.self) { index in
                        QuizOptionButton(
                            text: question.options[index],
                            flagCode: nil,
                            state: splitOptionState(
                                index: index,
                                correctIndex: question.correctIndex,
                                selectedAnswer: selectedAnswer
                            ),
                            index: index
                        ) {
                            onSelect(index)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.sm)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .frame(maxHeight: .infinity)
    }

    func splitOptionState(
        index: Int,
        correctIndex: Int,
        selectedAnswer: Int?
    ) -> QuizOptionButton.OptionState {
        guard let selected = selectedAnswer else { return .default }
        if index == correctIndex { return .correct }
        if index == selected { return .incorrect }
        return .disabled
    }
}

// MARK: - Helpers

private extension ChallengeSplitScreen {
    var progressFraction: CGFloat {
        guard room.totalRounds > 0 else { return 0 }
        return CGFloat(currentRound - 1) / CGFloat(room.totalRounds)
    }

    var player1Question: ChallengeQuestion? {
        let index = (currentRound - 1) * 2
        guard index < room.questions.count else { return nil }
        return room.questions[index]
    }

    var player2Question: ChallengeQuestion? {
        let index = (currentRound - 1) * 2 + 1
        guard index < room.questions.count else { return nil }
        return room.questions[index]
    }

    func selectAnswer(playerIndex: Int, optionIndex: Int) {
        guard !showFeedback else { return }

        if playerIndex == 0, player1Answer == nil {
            player1Answer = optionIndex
            let correct = optionIndex == player1Question?.correctIndex
            if correct { room.player1Score += 1 }
            hapticsService.notification(correct ? .success : .error)
        } else if playerIndex == 1, player2Answer == nil {
            player2Answer = optionIndex
            let correct = optionIndex == player2Question?.correctIndex
            if correct { room.player2Score += 1 }
            hapticsService.notification(correct ? .success : .error)
        }

        if player1Answer != nil, player2Answer != nil {
            showFeedback = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                advanceRound()
            }
        }
    }

    func advanceRound() {
        if currentRound >= room.totalRounds {
            coordinator.path.append(room)
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentRound += 1
                player1Answer = nil
                player2Answer = nil
                showFeedback = false
            }
        }
    }
}
