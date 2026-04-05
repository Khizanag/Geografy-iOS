// swiftlint:disable file_length
import GameController
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import Geografy_Feature_Quiz
import SwiftUI

struct MultiplayerQuizScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss

    let countryDataService: CountryDataService
    let quizType: QuizType
    let region: QuizRegion
    let difficulty: QuizDifficulty
    let questionCount: Int

    @State private var phase: GamePhase = .lobby
    @State private var players: [Player] = []
    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var timeRemaining: Double = 15
    @State private var revealAnswers = false
    @State private var timer: Timer?
    @State private var showQuitConfirmation = false
    @State private var controllerObservers: [any NSObjectProtocol] = []

    private let playerColors: [Color] = [.blue, .red, .green, .orange]
    private let playerNames = ["Player 1", "Player 2", "Player 3", "Player 4"]

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            AmbientBlobsView(.tvQuiz)

            switch phase {
            case .lobby:
                lobbyView
            case .playing:
                if let question = currentQuestion {
                    gameView(question)
                }
            case .results:
                resultsView
            }
        }
        .onAppear { startControllerDiscovery() }
        .onDisappear { cleanupControllers() }
        .onExitCommand {
            if phase == .playing {
                showQuitConfirmation = true
            } else {
                dismiss()
            }
        }
        .confirmationDialog("Quit Game?", isPresented: $showQuitConfirmation, titleVisibility: .visible) {
            Button("Quit", role: .destructive) {
                timer?.invalidate()
                dismiss()
            }
            Button("Continue", role: .cancel) {}
        }
    }
}

// MARK: - Game Phase
extension MultiplayerQuizScreen {
    enum GamePhase {
        case lobby
        case playing
        case results
    }
}

// MARK: - Player
extension MultiplayerQuizScreen {
    struct Player: Identifiable {
        let id: Int
        let name: String
        let color: Color
        let controller: GCController
        var score: Int = 0
        var currentAnswer: UUID?
        var hasAnswered: Bool { currentAnswer != nil }
    }
}

// MARK: - Lobby
private extension MultiplayerQuizScreen {
    var lobbyView: some View {
        VStack(spacing: DesignSystem.Spacing.xxl) {
            Text("Multiplayer Quiz")
                .font(DesignSystem.Font.system(size: 52, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("Connect controllers and press any button to join")
                .font(DesignSystem.Font.system(size: 26))
                .foregroundStyle(DesignSystem.Color.textSecondary)

            HStack(spacing: DesignSystem.Spacing.xl) {
                ForEach(0..<4, id: \.self) { index in
                    playerSlot(index)
                }
            }

            if players.count >= 2 {
                Button {
                    startGame()
                } label: {
                    Label("Start Game", systemImage: "play.fill")
                        .font(DesignSystem.Font.system(size: 28, weight: .bold))
                }
                .buttonStyle(.bordered)
            } else {
                Text("Need at least 2 players")
                    .font(DesignSystem.Font.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
    }

    func playerSlot(_ index: Int) -> some View {
        let isJoined = index < players.count

        // swiftlint:disable:next closure_body_length
        return VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
                    .fill(
                        isJoined
                            ? playerColors[index].opacity(0.2)
                            : DesignSystem.Color.cardBackground.opacity(0.3)
                    )
                    .frame(width: 200, height: 220)

                if isJoined {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "gamecontroller.fill")
                            .font(DesignSystem.Font.system(size: 48))
                            .foregroundStyle(playerColors[index])

                        Text(playerNames[index])
                            .font(DesignSystem.Font.system(size: 22, weight: .bold))
                            .foregroundStyle(DesignSystem.Color.textPrimary)

                        Text("Ready")
                            .font(DesignSystem.Font.system(size: 22))
                            .foregroundStyle(DesignSystem.Color.success)
                    }
                } else {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "gamecontroller")
                            .font(DesignSystem.Font.system(size: 48))
                            .foregroundStyle(DesignSystem.Color.textTertiary)

                        Text("Press to Join")
                            .font(DesignSystem.Font.system(size: 22))
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                    }
                }
            }

            if isJoined {
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.xxs)
                    .fill(playerColors[index])
                    .frame(height: 4)
            }
        }
        .frame(width: 200)
    }
}

// MARK: - Game View
private extension MultiplayerQuizScreen {
    var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    func gameView(_ question: QuizQuestion) -> some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            headerBar

            promptSection(question)

            optionsSection(question)

            playerStatusBar
        }
        .padding(.horizontal, 80)
        .padding(.vertical, 40)
    }

    var headerBar: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                HStack {
                    Text("Q\(currentIndex + 1) / \(questions.count)")
                        .font(DesignSystem.Font.system(size: 24, weight: .bold))
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Spacer()

                    HStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(players) { player in
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Circle()
                                    .fill(player.color)
                                    .frame(width: 14, height: 14)
                                Text("\(player.score)")
                                    .font(DesignSystem.Font.system(size: 22, weight: .bold))
                                    .foregroundStyle(DesignSystem.Color.textPrimary)
                            }
                        }
                    }
                }

                timerView
            }

            progressBar
        }
        .focusable(false)
    }

    var progressBar: some View {
        GeometryReader { geometryReader in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DesignSystem.Color.cardBackground)

                Capsule()
                    .fill(DesignSystem.Color.accent)
                    .frame(
                        width: geometryReader.size.width * CGFloat(currentIndex)
                            / CGFloat(max(questions.count, 1))
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentIndex)
            }
        }
        .frame(height: 6)
    }

    var timerView: some View {
        ZStack {
            Circle()
                .stroke(DesignSystem.Color.cardBackground, lineWidth: 4)
                .frame(width: 60, height: 60)

            Circle()
                .trim(from: 0, to: timeRemaining / 15)
                .stroke(timerColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))

            Text("\(Int(timeRemaining))")
                .font(DesignSystem.Font.system(size: 24, weight: .bold))
                .foregroundStyle(timerColor)
        }
    }

    var timerColor: Color {
        if timeRemaining > 10 { return DesignSystem.Color.success }
        if timeRemaining > 5 { return DesignSystem.Color.warning }
        return DesignSystem.Color.error
    }

    var isFlagOptionsLayout: Bool {
        currentQuestion?.options.contains { $0.flagCode != nil && $0.text == nil } ?? false
    }

    var isFlagPromptLayout: Bool {
        currentQuestion?.promptFlag != nil
    }

    func promptSection(_ question: QuizQuestion) -> some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if let flagCode = question.promptFlag {
                FlagView(
                    countryCode: flagCode,
                    height: isFlagPromptLayout && !isFlagOptionsLayout ? 180 : 120
                )
            }

            HStack(spacing: DesignSystem.Spacing.xs) {
                Text(question.promptText)
                    .font(DesignSystem.Font.system(size: 34, weight: .semibold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                if let subject = question.promptSubject {
                    Text(subject)
                        .font(DesignSystem.Font.system(size: 34, weight: .bold))
                        .foregroundStyle(DesignSystem.Color.accent)
                }
            }
            .multilineTextAlignment(.center)
        }
        .focusable(false)
    }

    func optionsSection(_ question: QuizQuestion) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.lg),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.lg),
            ],
            spacing: DesignSystem.Spacing.lg
        ) {
            ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                if isFlagOptionsLayout {
                    flagOptionCard(option, question: question, index: index)
                } else {
                    optionCard(option, question: question, index: index)
                }
            }
        }
        .frame(maxWidth: isFlagOptionsLayout ? 1_100 : 900)
        .focusable(false)
    }

    func optionCard(_ option: QuizOption, question: QuizQuestion, index: Int) -> some View {
        let isCorrect = option.id == question.correctOptionID
        let gamepadButton = GamepadButton.allCases.indices.contains(index)
            ? GamepadButton.allCases[index]
            : nil
        let playersWhoChose = players.filter { $0.currentAnswer == option.id }
        let backgroundColor = multiplayerOptionColor(
            isCorrect: isCorrect,
            hasPlayerSelections: !playersWhoChose.isEmpty
        )

        return HStack(spacing: DesignSystem.Spacing.md) {
            if let gamepadButton {
                Image(systemName: gamepadButton.icon)
                    .font(DesignSystem.Font.system(size: 22))
                    .foregroundStyle(gamepadButton.color)
                    .frame(width: 36)
            }

            if let flagCode = option.flagCode {
                FlagView(countryCode: flagCode, height: 36)
            }

            Text(option.text ?? "")
                .font(DesignSystem.Font.system(size: 24, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Spacer()

            if revealAnswers {
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(DesignSystem.Font.system(size: 26))
                        .foregroundStyle(DesignSystem.Color.success)
                }

                HStack(spacing: DesignSystem.Spacing.xxs) {
                    ForEach(playersWhoChose) { player in
                        Circle()
                            .fill(player.color)
                            .frame(width: 16, height: 16)
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            backgroundColor,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
        )
    }

    func flagOptionCard(_ option: QuizOption, question: QuizQuestion, index: Int) -> some View {
        let isCorrect = option.id == question.correctOptionID
        let gamepadButton = GamepadButton.allCases.indices.contains(index)
            ? GamepadButton.allCases[index]
            : nil
        let playersWhoChose = players.filter { $0.currentAnswer == option.id }
        let backgroundColor = multiplayerOptionColor(
            isCorrect: isCorrect,
            hasPlayerSelections: !playersWhoChose.isEmpty
        )

        return VStack(spacing: DesignSystem.Spacing.sm) {
            if let flagCode = option.flagCode {
                FlagView(countryCode: flagCode, height: 90)
            }

            if let gamepadButton {
                Image(systemName: gamepadButton.icon)
                    .font(DesignSystem.Font.system(size: 22))
                    .foregroundStyle(gamepadButton.color)
            }

            if revealAnswers {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .font(DesignSystem.Font.system(size: 22))
                            .foregroundStyle(DesignSystem.Color.success)
                    }

                    HStack(spacing: DesignSystem.Spacing.xxs) {
                        ForEach(playersWhoChose) { player in
                            Circle()
                                .fill(player.color)
                                .frame(width: 14, height: 14)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(
            backgroundColor,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
        )
    }

    var playerStatusBar: some View {
        // swiftlint:disable:next closure_body_length
        HStack(spacing: DesignSystem.Spacing.lg) {
            // swiftlint:disable:next closure_body_length
            ForEach(players) { player in
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Circle()
                        .fill(player.color)
                        .frame(width: 18, height: 18)

                    Text(player.name)
                        .font(DesignSystem.Font.system(size: 20, weight: .semibold))
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    if revealAnswers {
                        let isCorrect = player.currentAnswer == currentQuestion?.correctOptionID
                        Image(systemName: player.hasAnswered ? (isCorrect ? "checkmark" : "xmark") : "minus")
                            .font(DesignSystem.Font.system(size: 22, weight: .bold))
                            .foregroundStyle(
                                !player.hasAnswered
                                    ? DesignSystem.Color.textTertiary
                                    : isCorrect ? DesignSystem.Color.success : DesignSystem.Color.error
                            )
                    } else {
                        Image(systemName: player.hasAnswered ? "checkmark.circle.fill" : "ellipsis.circle")
                            .font(DesignSystem.Font.system(size: 20))
                            .foregroundStyle(
                                player.hasAnswered
                                    ? DesignSystem.Color.success
                                    : DesignSystem.Color.textTertiary
                            )
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    DesignSystem.Color.cardBackground.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                )
            }
        }
        .focusable(false)
    }
}

// MARK: - Results
private extension MultiplayerQuizScreen {
    var resultsView: some View {
        // swiftlint:disable:next closure_body_length
        VStack(spacing: DesignSystem.Spacing.xxl) {
            Text("Final Scores")
                .font(DesignSystem.Font.system(size: 52, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            let ranked = players.sorted(by: \.score, descending: true)

            ForEach(Array(ranked.enumerated()), id: \.element.id) { rank, player in
                HStack(spacing: DesignSystem.Spacing.lg) {
                    Text(rankMedal(rank))
                        .font(DesignSystem.Font.system(size: 48))

                    Circle()
                        .fill(player.color)
                        .frame(width: 24, height: 24)

                    Text(player.name)
                        .font(DesignSystem.Font.system(size: 32, weight: .bold))
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Spacer()

                    Text("\(player.score) / \(questions.count)")
                        .font(DesignSystem.Font.system(size: 32, weight: .bold))
                        .foregroundStyle(DesignSystem.Color.accent)
                }
                .padding(DesignSystem.Spacing.lg)
                .background(
                    rank == 0
                        ? player.color.opacity(0.15)
                        : DesignSystem.Color.cardBackground.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                )
                .frame(maxWidth: 700)
            }

            HStack(spacing: DesignSystem.Spacing.xl) {
                Button {
                    restartGame()
                } label: {
                    Label("Play Again", systemImage: "arrow.counterclockwise")
                        .font(DesignSystem.Font.system(size: 24, weight: .semibold))
                }
                .buttonStyle(.bordered)

                Button {
                    timer?.invalidate()
                    dismiss()
                } label: {
                    Label("Done", systemImage: "checkmark")
                        .font(DesignSystem.Font.system(size: 24, weight: .semibold))
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(80)
    }

    func rankMedal(_ rank: Int) -> String {
        switch rank {
        case 0: "\u{1F947}"
        case 1: "\u{1F948}"
        case 2: "\u{1F949}"
        default: "  "
        }
    }
}

// MARK: - Helpers
private extension MultiplayerQuizScreen {
    func multiplayerOptionColor(isCorrect: Bool, hasPlayerSelections: Bool) -> Color {
        guard revealAnswers else { return DesignSystem.Color.cardBackground.opacity(0.6) }
        if isCorrect { return DesignSystem.Color.success.opacity(0.4) }
        if hasPlayerSelections { return DesignSystem.Color.error.opacity(0.3) }
        return DesignSystem.Color.cardBackground.opacity(0.4)
    }
}

// MARK: - Game Logic
private extension MultiplayerQuizScreen {
    func startGame() {
        let filteredCountries = region.filter(countryDataService.countries)
        questions = QuestionGenerator.generate(
            type: quizType,
            countries: filteredCountries,
            count: questionCount,
            optionCount: 4,
        )
        currentIndex = 0
        phase = .playing
        startRound()
    }

    func startRound() {
        for index in players.indices {
            players[index].currentAnswer = nil
        }
        revealAnswers = false
        timeRemaining = 15
        startTimer()
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                if timeRemaining > 0 {
                    timeRemaining -= 0.1

                    if Int(timeRemaining * 10).isMultiple(of: 10), timeRemaining <= 5, timeRemaining > 0 {
                        for player in players {
                            ControllerHaptics.shared.playTimerWarning(on: player.controller)
                        }
                    }
                } else {
                    revealRound()
                }
            }
        }
    }

    func playerAnswered(playerIndex: Int, optionIndex: Int) {
        guard !revealAnswers,
              playerIndex < players.count,
              let question = currentQuestion,
              optionIndex < question.options.count,
              !players[playerIndex].hasAnswered
        else { return }

        players[playerIndex].currentAnswer = question.options[optionIndex].id
        ControllerHaptics.shared.playTap(on: players[playerIndex].controller)

        if players.allSatisfy(\.hasAnswered) {
            revealRound()
        }
    }

    func revealRound() {
        timer?.invalidate()
        revealAnswers = true

        guard let question = currentQuestion else { return }
        for index in players.indices {
            let isCorrect = players[index].currentAnswer == question.correctOptionID
            if isCorrect {
                players[index].score += 1
            }

            if players[index].hasAnswered {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                    if isCorrect {
                        ControllerHaptics.shared.playCorrect(on: players[index].controller)
                    } else {
                        ControllerHaptics.shared.playWrong(on: players[index].controller)
                    }
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            advanceToNext()
        }
    }

    func advanceToNext() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            startRound()
        } else {
            phase = .results
            if let winner = players.max(by: { $0.score < $1.score }) {
                ControllerHaptics.shared.playCelebration(on: winner.controller)
            }
        }
    }

    func restartGame() {
        for index in players.indices {
            players[index].score = 0
        }
        startGame()
    }
}

// MARK: - Controller Management
private extension MultiplayerQuizScreen {
    func startControllerDiscovery() {
        scanAndRegisterControllers()

        let token = NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { _ in
            scanAndRegisterControllers()
        }
        controllerObservers.append(token)
    }

    nonisolated func scanAndRegisterControllers() {
        let controllers = GCController.controllers()
        Task { @MainActor in
            for controller in controllers where controller.extendedGamepad != nil {
                registerControllerForJoin(controller)
            }
        }
    }

    func registerControllerForJoin(_ controller: GCController) {
        guard let gamepad = controller.extendedGamepad else { return }

        let joinHandler: GCControllerButtonValueChangedHandler = { [self] _, _, pressed in
            guard pressed else { return }
            Task { @MainActor in
                joinPlayer(controller: controller)
            }
        }

        gamepad.buttonA.pressedChangedHandler = joinHandler
        gamepad.leftShoulder.pressedChangedHandler = joinHandler
        gamepad.rightShoulder.pressedChangedHandler = joinHandler
    }

    func joinPlayer(controller: GCController) {
        guard phase == .lobby,
              players.count < 4,
              !players.contains(where: { $0.controller === controller })
        else { return }

        let index = players.count
        let color = controllerColor(for: controller, fallbackIndex: index)

        let player = Player(
            id: index,
            name: playerNames[index],
            color: color,
            controller: controller
        )
        players.append(player)

        setControllerLight(controller, color: color)
        controller.playerIndex = GCControllerPlayerIndex(rawValue: index) ?? .indexUnset

        bindPlayerControls(playerIndex: index, controller: controller)
    }

    func controllerColor(for controller: GCController, fallbackIndex: Int) -> Color {
        guard let light = controller.light else {
            return playerColors[fallbackIndex]
        }

        let red = Double(light.color.red)
        let green = Double(light.color.green)
        let blue = Double(light.color.blue)

        let isDefault = (red < 0.1 && green < 0.1 && blue < 0.1)
            || (red > 0.9 && green > 0.9 && blue > 0.9)

        if isDefault {
            return playerColors[fallbackIndex]
        }

        return Color(red: red, green: green, blue: blue)
    }

    func setControllerLight(_ controller: GCController, color: Color) {
        guard let light = controller.light else { return }

        let resolved = color.resolve(in: EnvironmentValues())
        light.color = GCColor(
            red: resolved.red,
            green: resolved.green,
            blue: resolved.blue
        )
    }

    func bindPlayerControls(playerIndex: Int, controller: GCController) {
        guard let gamepad = controller.extendedGamepad else { return }

        gamepad.leftShoulder.pressedChangedHandler = { [self] _, _, pressed in
            guard pressed else { return }
            Task { @MainActor in playerAnswered(playerIndex: playerIndex, optionIndex: 0) }
        }

        gamepad.rightShoulder.pressedChangedHandler = { [self] _, _, pressed in
            guard pressed else { return }
            Task { @MainActor in playerAnswered(playerIndex: playerIndex, optionIndex: 1) }
        }

        gamepad.leftTrigger.pressedChangedHandler = { [self] _, _, pressed in
            guard pressed else { return }
            Task { @MainActor in playerAnswered(playerIndex: playerIndex, optionIndex: 2) }
        }

        gamepad.rightTrigger.pressedChangedHandler = { [self] _, _, pressed in
            guard pressed else { return }
            Task { @MainActor in playerAnswered(playerIndex: playerIndex, optionIndex: 3) }
        }
    }

    func cleanupControllers() {
        timer?.invalidate()
        for observer in controllerObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        controllerObservers.removeAll()

        for controller in GCController.controllers() {
            guard let gamepad = controller.extendedGamepad else { continue }
            gamepad.leftShoulder.pressedChangedHandler = nil
            gamepad.rightShoulder.pressedChangedHandler = nil
            gamepad.leftTrigger.pressedChangedHandler = nil
            gamepad.rightTrigger.pressedChangedHandler = nil
            gamepad.buttonA.pressedChangedHandler = nil
        }
    }
}
