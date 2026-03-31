// swiftlint:disable file_length
import GameController
import SwiftUI
import GeografyDesign
import GeografyCore

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
        VStack(spacing: 48) {
            Text("Multiplayer Quiz")
                .font(.system(size: 52, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("Connect controllers and press any button to join")
                .font(.system(size: 26))
                .foregroundStyle(DesignSystem.Color.textSecondary)

            HStack(spacing: 32) {
                ForEach(0..<4, id: \.self) { index in
                    playerSlot(index)
                }
            }

            if players.count >= 2 {
                Button {
                    startGame()
                } label: {
                    Label("Start Game", systemImage: "play.fill")
                        .font(.system(size: 28, weight: .bold))
                }
                .buttonStyle(.bordered)
            } else {
                Text("Need at least 2 players")
                    .font(.system(size: 22))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
    }

    func playerSlot(_ index: Int) -> some View {
        let isJoined = index < players.count

        return VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isJoined
                            ? playerColors[index].opacity(0.2)
                            : DesignSystem.Color.cardBackground.opacity(0.3)
                    )
                    .frame(width: 200, height: 220)

                if isJoined {
                    VStack(spacing: 12) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(playerColors[index])

                        Text(playerNames[index])
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(DesignSystem.Color.textPrimary)

                        Text("Ready")
                            .font(.system(size: 22))
                            .foregroundStyle(DesignSystem.Color.success)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "gamecontroller")
                            .font(.system(size: 48))
                            .foregroundStyle(DesignSystem.Color.textTertiary)

                        Text("Press to Join")
                            .font(.system(size: 22))
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                    }
                }
            }

            if isJoined {
                RoundedRectangle(cornerRadius: 4)
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
        VStack(spacing: 32) {
            headerBar

            promptSection(question)

            optionsSection(question)

            playerStatusBar
        }
        .padding(.horizontal, 80)
        .padding(.vertical, 40)
    }

    var headerBar: some View {
        VStack(spacing: 16) {
            ZStack {
                HStack {
                    Text("Q\(currentIndex + 1) / \(questions.count)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Spacer()

                    HStack(spacing: 16) {
                        ForEach(players) { player in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(player.color)
                                    .frame(width: 14, height: 14)
                                Text("\(player.score)")
                                    .font(.system(size: 22, weight: .bold))
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
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DesignSystem.Color.cardBackground)

                Capsule()
                    .fill(DesignSystem.Color.accent)
                    .frame(width: geometry.size.width * CGFloat(currentIndex) / CGFloat(max(questions.count, 1)))
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
                .font(.system(size: 24, weight: .bold))
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
        VStack(spacing: 16) {
            if let flagCode = question.promptFlag {
                FlagView(countryCode: flagCode, height: isFlagPromptLayout && !isFlagOptionsLayout ? 180 : 120)
            }

            HStack(spacing: 8) {
                Text(question.promptText)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                if let subject = question.promptSubject {
                    Text(subject)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(DesignSystem.Color.accent)
                }
            }
            .multilineTextAlignment(.center)
        }
        .focusable(false)
    }

    func optionsSection(_ question: QuizQuestion) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 24), GridItem(.flexible(), spacing: 24)],
            spacing: 24
        ) {
            ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                if isFlagOptionsLayout {
                    flagOptionCard(option, question: question, index: index)
                } else {
                    optionCard(option, question: question, index: index)
                }
            }
        }
        .frame(maxWidth: isFlagOptionsLayout ? 1100 : 900)
        .focusable(false)
    }

    func optionCard(_ option: QuizOption, question: QuizQuestion, index: Int) -> some View {
        let isCorrect = option.id == question.correctOptionID
        let gamepadButton = GamepadButton.allCases.indices.contains(index) ? GamepadButton.allCases[index] : nil
        let playersWhoChose = players.filter { $0.currentAnswer == option.id }

        let backgroundColor: Color = {
            guard revealAnswers else { return DesignSystem.Color.cardBackground.opacity(0.6) }
            if isCorrect { return DesignSystem.Color.success.opacity(0.4) }
            if !playersWhoChose.isEmpty { return DesignSystem.Color.error.opacity(0.3) }
            return DesignSystem.Color.cardBackground.opacity(0.4)
        }()

        return HStack(spacing: 16) {
            if let gamepadButton {
                Image(systemName: gamepadButton.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(gamepadButton.color)
                    .frame(width: 36)
            }

            if let flagCode = option.flagCode {
                FlagView(countryCode: flagCode, height: 36)
            }

            Text(option.text ?? "")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Spacer()

            if revealAnswers {
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(DesignSystem.Color.success)
                }

                HStack(spacing: 4) {
                    ForEach(playersWhoChose) { player in
                        Circle()
                            .fill(player.color)
                            .frame(width: 16, height: 16)
                    }
                }
            }
        }
        .padding(20)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 16))
    }

    func flagOptionCard(_ option: QuizOption, question: QuizQuestion, index: Int) -> some View {
        let isCorrect = option.id == question.correctOptionID
        let gamepadButton = GamepadButton.allCases.indices.contains(index) ? GamepadButton.allCases[index] : nil
        let playersWhoChose = players.filter { $0.currentAnswer == option.id }

        let backgroundColor: Color = {
            guard revealAnswers else { return DesignSystem.Color.cardBackground.opacity(0.6) }
            if isCorrect { return DesignSystem.Color.success.opacity(0.4) }
            if !playersWhoChose.isEmpty { return DesignSystem.Color.error.opacity(0.3) }
            return DesignSystem.Color.cardBackground.opacity(0.4)
        }()

        return VStack(spacing: 12) {
            if let flagCode = option.flagCode {
                FlagView(countryCode: flagCode, height: 90)
            }

            if let gamepadButton {
                Image(systemName: gamepadButton.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(gamepadButton.color)
            }

            if revealAnswers {
                HStack(spacing: 8) {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(DesignSystem.Color.success)
                    }

                    HStack(spacing: 4) {
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
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 20))
    }

    var playerStatusBar: some View {
        HStack(spacing: 24) {
            ForEach(players) { player in
                HStack(spacing: 12) {
                    Circle()
                        .fill(player.color)
                        .frame(width: 18, height: 18)

                    Text(player.name)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    if revealAnswers {
                        let isCorrect = player.currentAnswer == currentQuestion?.correctOptionID
                        Image(systemName: player.hasAnswered ? (isCorrect ? "checkmark" : "xmark") : "minus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(
                                !player.hasAnswered
                                    ? DesignSystem.Color.textTertiary
                                    : isCorrect ? DesignSystem.Color.success : DesignSystem.Color.error
                            )
                    } else {
                        Image(systemName: player.hasAnswered ? "checkmark.circle.fill" : "ellipsis.circle")
                            .font(.system(size: 20))
                            .foregroundStyle(
                                player.hasAnswered
                                    ? DesignSystem.Color.success
                                    : DesignSystem.Color.textTertiary
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    DesignSystem.Color.cardBackground.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 12)
                )
            }
        }
        .focusable(false)
    }
}

// MARK: - Results
private extension MultiplayerQuizScreen {
    var resultsView: some View {
        VStack(spacing: 48) {
            Text("Final Scores")
                .font(.system(size: 52, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            let ranked = players.sorted { $0.score > $1.score }

            ForEach(Array(ranked.enumerated()), id: \.element.id) { rank, player in
                HStack(spacing: 24) {
                    Text(rankMedal(rank))
                        .font(.system(size: 48))

                    Circle()
                        .fill(player.color)
                        .frame(width: 24, height: 24)

                    Text(player.name)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Spacer()

                    Text("\(player.score) / \(questions.count)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(DesignSystem.Color.accent)
                }
                .padding(24)
                .background(
                    rank == 0
                        ? player.color.opacity(0.15)
                        : DesignSystem.Color.cardBackground.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .frame(maxWidth: 700)
            }

            HStack(spacing: 32) {
                Button {
                    restartGame()
                } label: {
                    Label("Play Again", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 24, weight: .semibold))
                }
                .buttonStyle(.bordered)

                Button {
                    timer?.invalidate()
                    dismiss()
                } label: {
                    Label("Done", systemImage: "checkmark")
                        .font(.system(size: 24, weight: .semibold))
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(80)
    }

    func rankMedal(_ rank: Int) -> String {
        switch rank {
        case 0: "🥇"
        case 1: "🥈"
        case 2: "🥉"
        default: "  "
        }
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

                    if Int(timeRemaining * 10) % 10 == 0, timeRemaining <= 5, timeRemaining > 0 {
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

        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { _ in
            scanAndRegisterControllers()
        }
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
        NotificationCenter.default.removeObserver(self, name: .GCControllerDidConnect, object: nil)

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
