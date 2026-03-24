import SwiftUI

struct ChallengeSplitScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService

    @State private var room: ChallengeRoom
    @State private var player1Answer: Int?
    @State private var player2Answer: Int?
    @State private var currentRound = 1
    @State private var showFeedback = false
    @State private var isFinished = false

    private let challengeRoomService: ChallengeRoomService

    init(room: ChallengeRoom, challengeRoomService: ChallengeRoomService) {
        _room = State(initialValue: room)
        self.challengeRoomService = challengeRoomService
    }

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()

            if isFinished {
                ChallengeResultScreen(
                    room: room,
                    challengeRoomService: challengeRoomService
                ) {
                    dismiss()
                }
            } else {
                splitContent
            }
        }
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

            Divider()
                .background(DesignSystem.Color.accent)

            centerBar

            Divider()
                .background(DesignSystem.Color.accent)

            playerHalf(
                playerIndex: 0,
                question: player1Question,
                selectedAnswer: player1Answer,
                onSelect: { selectAnswer(playerIndex: 0, optionIndex: $0) }
            )
        }
        .ignoresSafeArea(edges: .vertical)
    }

    var centerBar: some View {
        HStack {
            Text("P1: \(room.player1Score)")
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.blue)

            Spacer()

            Text("Round \(String(currentRound))/\(String(room.totalRounds))")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)

            Spacer()

            Text("P2: \(room.player2Score)")
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.orange)

            Spacer()

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .buttonStyle(.plain)
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
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text(playerIndex == 0 ? "Player 1" : "Player 2")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(playerIndex == 0 ? DesignSystem.Color.blue : DesignSystem.Color.orange)

                Spacer()

                Text("\(playerIndex == 0 ? room.player1Score : room.player2Score) pts")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)

            if let question {
                Text(question.question)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, DesignSystem.Spacing.md)

                splitOptions(
                    question: question,
                    selectedAnswer: selectedAnswer,
                    onSelect: onSelect
                )
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .frame(maxHeight: .infinity)
    }

    func splitOptions(
        question: ChallengeQuestion,
        selectedAnswer: Int?,
        onSelect: @escaping (Int) -> Void
    ) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: DesignSystem.Spacing.xs
        ) {
            ForEach(question.options.indices, id: \.self) { index in
                splitOptionButton(
                    text: question.options[index],
                    index: index,
                    correctIndex: question.correctIndex,
                    selectedAnswer: selectedAnswer,
                    onSelect: onSelect
                )
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
    }

    func splitOptionButton(
        text: String,
        index: Int,
        correctIndex: Int,
        selectedAnswer: Int?,
        onSelect: @escaping (Int) -> Void
    ) -> some View {
        let isSelected = selectedAnswer == index
        let isCorrect = index == correctIndex
        let answered = selectedAnswer != nil

        return Button { onSelect(index) } label: {
            Text(text)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .padding(.horizontal, DesignSystem.Spacing.xxs)
                .background(
                    splitOptionBackground(
                        isSelected: isSelected,
                        isCorrect: isCorrect,
                        answered: answered
                    ),
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                )
        }
        .buttonStyle(PressButtonStyle())
        .disabled(answered)
    }

    func splitOptionBackground(isSelected: Bool, isCorrect: Bool, answered: Bool) -> Color {
        guard answered else { return DesignSystem.Color.cardBackground }
        if isCorrect { return DesignSystem.Color.success.opacity(0.2) }
        if isSelected { return DesignSystem.Color.error.opacity(0.2) }
        return DesignSystem.Color.cardBackground
    }
}

// MARK: - Helpers

private extension ChallengeSplitScreen {
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
            withAnimation { isFinished = true }
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
