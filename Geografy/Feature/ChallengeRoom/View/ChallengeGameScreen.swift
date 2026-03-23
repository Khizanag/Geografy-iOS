import SwiftUI

struct ChallengeGameScreen: View {
    @Environment(\.dismiss) private var dismiss

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
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            if room.isFinished {
                ChallengeResultScreen(room: room, challengeRoomService: challengeRoomService) {
                    dismiss()
                }
            } else if showingPassScreen {
                passScreen
            } else {
                questionScreen
            }
        }
    }
}

// MARK: - Subviews

private extension ChallengeGameScreen {
    var passScreen: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            passIcon
            passLabel
            Spacer()
            passButton
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.xl)
    }

    var passIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.orange.opacity(0.25), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
            Image(systemName: "hand.point.right.fill")
                .font(.system(size: 48))
                .foregroundStyle(DesignSystem.Color.orange)
        }
    }

    var passLabel: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("Pass to")
                .font(.title2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Text(room.currentPlayerName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Round \(room.roundNumber) of \(room.totalRounds)")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .padding(.top, DesignSystem.Spacing.xs)
            scoreRow
        }
    }

    var scoreRow: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            scoreChip(name: room.player1Name, score: room.player1Score, isActive: room.currentPlayerIndex == 0)
            Text("vs")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            scoreChip(name: room.player2Name, score: room.player2Score, isActive: room.currentPlayerIndex == 1)
        }
        .padding(.top, DesignSystem.Spacing.sm)
    }

    func scoreChip(name: String, score: Int, isActive: Bool) -> some View {
        VStack(spacing: 2) {
            Text("\(score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(isActive ? DesignSystem.Color.accent : DesignSystem.Color.textSecondary)
            Text(name)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
    }

    var passButton: some View {
        GlassButton("I'm Ready — Show Question", fullWidth: true) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingPassScreen = false
                selectedOptionIndex = nil
                showingResult = false
            }
        }
    }

    var questionScreen: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            progressBar
            if let question = room.currentQuestion {
                questionCard(question)
                optionsGrid(question)
            }
            if showingResult {
                nextButton
            }
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.xl)
    }

    var progressBar: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack {
                Text(room.currentPlayerName)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer()
                Text("Round \(room.roundNumber)/\(room.totalRounds)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            GeometryReader { geometryReader in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignSystem.Color.accent.opacity(0.15))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignSystem.Color.accent)
                        .frame(
                            width: geometryReader.size.width * progressRatio,
                            height: 6
                        )
                        .animation(.easeInOut(duration: 0.3), value: room.roundNumber)
                }
            }
            .frame(height: 6)
        }
    }

    func questionCard(_ question: ChallengeQuestion) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(question.category)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(question.question)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    func optionsGrid(_ question: ChallengeQuestion) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(question.options.indices, id: \.self) { index in
                optionButton(
                    text: question.options[index],
                    index: index,
                    correctIndex: question.correctIndex,
                    question: question
                )
            }
        }
    }

    func optionButton(text: String, index: Int, correctIndex: Int, question: ChallengeQuestion) -> some View {
        let isSelected = selectedOptionIndex == index
        let isCorrect = index == correctIndex
        let backgroundColor = optionBackground(
            isSelected: isSelected,
            isCorrect: isCorrect,
            showingResult: showingResult
        )

        return Button {
            guard !showingResult else { return }
            selectedOptionIndex = index
            wasCorrect = index == correctIndex
            challengeRoomService.score(room: &room, wasCorrect: wasCorrect)
            withAnimation(.easeInOut(duration: 0.25)) {
                showingResult = true
            }
        } label: {
            HStack {
                Text(text)
                    .font(DesignSystem.Font.body)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if showingResult, isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(DesignSystem.Color.success)
                } else if showingResult, isSelected, !isCorrect {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DesignSystem.Color.error)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        }
        .buttonStyle(PressButtonStyle())
        .disabled(showingResult)
    }

    var nextButton: some View {
        GlassButton(isLastTurnInGame ? "See Results" : "Next", fullWidth: true) {
            advanceToNext()
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Actions

private extension ChallengeGameScreen {
    var progressRatio: Double {
        let totalQuestions = Double(room.totalRounds)
        let currentRound = Double(room.roundNumber)
        return min(currentRound / totalQuestions, 1.0)
    }

    var isLastTurnInGame: Bool {
        room.roundNumber == room.totalRounds && room.currentPlayerIndex == 1
    }

    func optionBackground(isSelected: Bool, isCorrect: Bool, showingResult: Bool) -> Color {
        guard showingResult else {
            return isSelected ? DesignSystem.Color.accent.opacity(0.15) : DesignSystem.Color.cardBackground
        }
        if isCorrect { return DesignSystem.Color.success.opacity(0.15) }
        if isSelected { return DesignSystem.Color.error.opacity(0.15) }
        return DesignSystem.Color.cardBackground
    }

    func advanceToNext() {
        challengeRoomService.advance(room: &room)
        if !room.isFinished {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingPassScreen = true
                showingResult = false
                selectedOptionIndex = nil
            }
        }
    }
}
