import Geografy_Core_Common
#if !os(tvOS)
import Geografy_Core_Map
import Geografy_Core_Service
import MultipeerConnectivity
import SwiftUI

@MainActor
@Observable
public final class LocalMultiplayerCoordinator {
    public let sessionManager: MultipeerSessionManager
    /// The name the other player sees.
    public let playerName: String

    private(set) var state: LocalMatchState = .idle
    private(set) var isHost = false
    private(set) var opponent: PeerPlayer?
    private(set) var questions: [QuizQuestion] = []
    private(set) var currentIndex = 0
    private(set) var playerScore = 0
    private(set) var opponentScore = 0
    private(set) var opponentHasAnswered = false
    private(set) var playerAnsweredCurrent = false
    private(set) var matchConfig: PeerMessage.MatchConfig?
    /// The other player asked for a rematch and is waiting for an answer.
    public var rematchRequested = false
    /// This player asked for a rematch and is waiting for the other's answer.
    private(set) var isAwaitingRematch = false
    private(set) var rematchDeclined = false
    private(set) var questionTimerExpired = false
    /// The guest said they're ready; the host waits for it before starting.
    private(set) var isReady = false
    /// The host the guest tapped, while the invitation is out.
    private(set) var joiningPeer: MCPeerID?
    /// The host that didn't let the guest in, to say so under Nearby Hosts.
    private(set) var failedJoinName: String?
    /// A guest who left the host's lobby, so the host knows why it's waiting again.
    private(set) var departedPlayerName: String?
    /// The other player left after the result, so a rematch can't happen.
    private(set) var opponentLeftAfterMatch = false
    private(set) var ending: LocalMatchEnding?

    public var quizType: QuizType = .flagQuiz { didSet { shareSettings() } }
    public var region: QuizRegion = .world { didSet { shareSettings() } }
    public var difficulty: QuizDifficulty = .easy { didSet { shareSettings() } }
    public var questionCount: QuestionCount = .ten { didSet { shareSettings() } }
    public var comparisonMetric: ComparisonMetric = .population { didSet { shareSettings() } }
    public var game: LocalGame = .quiz { didSet { shareSettings() } }
    public var pinDropConfiguration = PinDropConfiguration(region: .world) { didSet { shareSettings() } }
    /// Nil for the whole world.
    var mapPuzzleContinent: Country.Continent? { didSet { shareSettings() } }
    var mapPuzzleQuestionCount: QuestionCount = .ten { didSet { shareSettings() } }
    var wordSearchTheme: WordSearchTheme = .countries { didSet { shareSettings() } }

    /// The countries a Pin Drop match finds, in order, chosen by the host.
    /// What the host picked for a game other than a quiz.
    private(set) var gameSetup: LocalGameSetup?
    private var opponentScoredRounds: Set<Int> = []
    private var hasFinishedRounds = false
    private var opponentHasFinishedRounds = false

    var activeGame: LocalGame {
        isHost ? game : matchConfig?.game ?? game
    }

    var activePinDropConfiguration: PinDropConfiguration {
        isHost ? pinDropConfiguration : matchConfig?.pinDrop ?? pinDropConfiguration
    }

    /// The quiz being played: the host's own choice, or the settings the host sent.
    var activeQuizType: QuizType {
        isHost ? quizType : matchConfig?.quizType ?? quizType
    }

    var activeDifficulty: QuizDifficulty {
        isHost ? difficulty : matchConfig?.difficulty ?? difficulty
    }

    /// The quiz's region, which a Speed Run races through too.
    var activeRegion: QuizRegion {
        isHost ? region : matchConfig?.region ?? region
    }

    var activeMapPuzzleContinent: Country.Continent? {
        isHost ? mapPuzzleContinent : matchConfig?.mapPuzzleContinent
    }

    private let countryDataService: CountryDataService
    private let geoJSONCache: GeoJSONCache
    private var opponentAnswers: [Int: (optionID: UUID, timeSpent: TimeInterval)] = [:]
    private var playerAnswers: [Int: (optionID: UUID, timeSpent: TimeInterval)] = [:]
    private var countdownTask: Task<Void, Never>?
    private var advanceTask: Task<Void, Never>?
    private var startTask: Task<Void, Never>?
    private var questionTimerTask: Task<Void, Never>?
    private var isAdvancing = false
    private var xpAwarded = false

    public init(playerName: String, countryDataService: CountryDataService, geoJSONCache: GeoJSONCache) {
        self.playerName = playerName
        self.sessionManager = MultipeerSessionManager(displayName: playerName)
        self.countryDataService = countryDataService
        self.geoJSONCache = geoJSONCache
        sessionManager.onMessageReceived = { [weak self] _, message in
            self?.handleMessage(message)
        }
        sessionManager.onPeerStateChanged = { [weak self] peerID, peerState in
            self?.handlePeerStateChange(peerID, state: peerState)
        }
    }
}

// MARK: - Host Actions
extension LocalMultiplayerCoordinator {
    public func startHosting() {
        isHost = true
        ending = nil
        departedPlayerName = nil
        state = .advertising
        sessionManager.startAdvertising()
    }

    public func startMatch() {
        guard isHost, opponent?.isReady == true else { return }
        switch game {
        case .quiz: break
        case .mapPuzzle:
            startMapPuzzleMatch()
            return
        case .pinDrop:
            startPinDropMatch()
            return
        case .speedRun:
            start(.speedRun)
            return
        case .wordSearch:
            start(.wordSearch(WordSearchService().makePuzzle(theme: wordSearchTheme)))
            return
        }

        let regionCountries = region.filter(countryDataService.countries)
        let generated = QuestionGenerator.generate(
            type: quizType,
            countries: regionCountries,
            count: questionCount.rawValue,
            optionCount: max(difficulty.optionCount, 4),
            comparisonMetric: comparisonMetric
        )

        guard !generated.isEmpty else { return }
        questions = generated

        let serialized = generated.map { SerializableQuestion(from: $0) }
        matchConfig = currentConfig
        sessionManager.send(.startMatch(config: currentConfig, questions: serialized))
        beginCountdown()
    }
}

// MARK: - Guest Actions
extension LocalMultiplayerCoordinator {
    public func startBrowsing() {
        isHost = false
        ending = nil
        failedJoinName = nil
        state = .browsing
        sessionManager.startBrowsing()
    }

    public func joinHost(_ peerID: MCPeerID) {
        guard joiningPeer == nil else { return }
        joiningPeer = peerID
        failedJoinName = nil
        sessionManager.invitePeer(peerID)
    }

    public func markReady() {
        guard state == .lobby, !isReady else { return }
        isReady = true
        sessionManager.send(.lobbyReady)
    }
}

// MARK: - Game Actions
extension LocalMultiplayerCoordinator {
    public func submitAnswer(optionID: UUID, timeSpent: TimeInterval) {
        guard state == .playing, !playerAnsweredCurrent else { return }
        guard currentIndex < questions.count else { return }
        playerAnsweredCurrent = true
        questionTimerTask?.cancel()
        playerAnswers[currentIndex] = (optionID, timeSpent)

        if questions[currentIndex].correctOptionID == optionID {
            playerScore += 1
        }

        sessionManager.send(.answerSubmitted(
            questionIndex: currentIndex,
            optionID: optionID,
            timeSpent: timeSpent
        ))

        if isHost, opponentHasAnswered {
            advanceAfterDelay()
        }
    }

    public func skipTimedOut() {
        guard state == .playing, !playerAnsweredCurrent else { return }
        playerAnsweredCurrent = true
        questionTimerExpired = true
        sessionManager.send(.timedOut(questionIndex: currentIndex))

        if isHost, opponentHasAnswered {
            advanceAfterDelay()
        }
    }

    public func requestRematch() {
        guard !isAwaitingRematch, !opponentLeftAfterMatch else { return }
        isAwaitingRematch = true
        rematchDeclined = false
        sessionManager.send(.rematchRequest)
    }

    public func acceptRematch() {
        sessionManager.send(.rematchAccepted)
        resetForRematch()
    }

    public func declineRematch() {
        rematchRequested = false
        sessionManager.send(.rematchDeclined)
    }

    /// Leaves the lobby, the match, or the result. The other phone hears why.
    public func leave() {
        cancelAllTasks()
        sessionManager.disconnect()
        state = .idle
        opponent = nil
        resetMatchState()
    }
}

// MARK: - Message Handling
private extension LocalMultiplayerCoordinator {
    func handleMessage(_ message: PeerMessage) {
        switch message {
        case .playerInfo(let name): handlePlayerInfo(name)
        case .lobbySettings(let config): handleLobbySettings(config)
        case .lobbyReady: handleLobbyReady()
        case let .startMatch(config, serialized): handleStartMatch(config, serialized)
        case let .startGame(config, setup): handleStartGame(config, setup)
        case let .roundScored(round, points): handleRoundScored(round, points: points)
        case .finishedRounds: handleFinishedRounds()
        case let .answerSubmitted(index, optionID, _): handleOpponentAnswer(index, optionID: optionID)
        case .timedOut(let index): handleOpponentTimeout(index)
        case .advanceToNext(let index): handleAdvance(index)
        case let .matchFinished(hostScore, guestScore): handleMatchFinished(hostScore, guestScore)
        case .rematchRequest: handleRematchRequest()
        case .rematchAccepted: resetForRematch()
        case .rematchDeclined: handleRematchDeclined()
        case .disconnecting: handleOpponentGone(saidGoodbye: true)
        }
    }

    func handlePlayerInfo(_ name: String) {
        guard state == .lobby || state == .advertising || state == .browsing else { return }
        opponent?.displayName = name
    }

    func handleStartGame(_ config: PeerMessage.MatchConfig, _ setup: LocalGameSetup) {
        guard state == .lobby else { return }
        matchConfig = config
        gameSetup = setup
        beginCountdown()
    }

    func handleRoundScored(_ round: Int, points: Int) {
        guard state == .playing, !opponentScoredRounds.contains(round) else { return }
        opponentScoredRounds.insert(round)
        opponentScore += points
    }

    func handleFinishedRounds() {
        guard state == .playing else { return }
        opponentHasFinishedRounds = true
        finishIfDone()
    }

    func handleLobbySettings(_ config: PeerMessage.MatchConfig) {
        guard !isHost, state == .lobby else { return }
        matchConfig = config
    }

    func handleLobbyReady() {
        guard state == .lobby else { return }
        opponent?.isReady = true
    }

    func handleRematchRequest() {
        guard state == .finished else { return }
        // Both asked at once: that's a yes from each side.
        if isAwaitingRematch {
            acceptRematch()
        } else {
            rematchRequested = true
        }
    }

    func handleRematchDeclined() {
        guard isAwaitingRematch else { return }
        isAwaitingRematch = false
        rematchDeclined = true
    }

    func handleStartMatch(_ config: PeerMessage.MatchConfig, _ serialized: [SerializableQuestion]) {
        guard state == .lobby else { return }
        matchConfig = config
        questions = serialized.compactMap { $0.toQuizQuestion(using: countryDataService) }
        guard questions.count == serialized.count else {
            ending = .questionsFailed
            sessionManager.disconnect()
            state = .disconnected
            return
        }
        beginCountdown()
    }

    func handleOpponentAnswer(_ questionIndex: Int, optionID: UUID) {
        guard state == .playing, questionIndex == currentIndex else { return }
        opponentHasAnswered = true
        opponentAnswers[questionIndex] = (optionID, 0)

        if currentIndex < questions.count,
           questions[questionIndex].correctOptionID == optionID {
            opponentScore += 1
        }

        if isHost, playerAnsweredCurrent { advanceAfterDelay() }
    }

    func handleOpponentTimeout(_ questionIndex: Int) {
        guard state == .playing, questionIndex == currentIndex else { return }
        opponentHasAnswered = true
        if isHost, playerAnsweredCurrent { advanceAfterDelay() }
    }

    func handleAdvance(_ questionIndex: Int) {
        guard state == .playing else { return }
        advanceTo(questionIndex)
    }

    func handleMatchFinished(_ hostScore: Int, _ guestScore: Int) {
        guard state == .playing else { return }
        if !isHost {
            opponentScore = hostScore
            playerScore = guestScore
        }
        state = .finished
    }

    func handlePeerStateChange(_ peerID: MCPeerID, state peerState: MCSessionState) {
        switch peerState {
        case .connected:
            guard opponent == nil else { return }
            opponent = PeerPlayer(peerID: peerID)
            joiningPeer = nil
            departedPlayerName = nil
            state = .lobby
            sessionManager.send(.playerInfo(name: playerName))
            shareSettings()
            sessionManager.stopAdvertising()
            sessionManager.stopBrowsing()
        case .notConnected:
            if peerID == joiningPeer {
                joiningPeer = nil
                failedJoinName = peerID.displayName
            }
            guard peerID == opponent?.peerID else { return }
            handleOpponentGone(saidGoodbye: false)
        case .connecting:
            break
        @unknown default:
            break
        }
    }

    /// The other player left or dropped. A host's lobby opens again for someone new; a result stays on screen;
    /// anything else ends with a screen that says what happened.
    func handleOpponentGone(saidGoodbye: Bool) {
        guard let opponent else { return }
        let name = opponent.displayName
        cancelAllTasks()
        // A result keeps the opponent, so their name and score stay on screen.
        if state != .finished { self.opponent = nil }
        switch state {
        case .finished:
            opponentLeftAfterMatch = true
            rematchRequested = false
            isAwaitingRematch = false
            sessionManager.closeSession()
        case .lobby where isHost:
            departedPlayerName = name
            sessionManager.closeSession()
            state = .advertising
            sessionManager.startAdvertising()
        case .lobby:
            ending = saidGoodbye ? .hostClosedLobby(name: name) : .connectionLost(name: name)
            sessionManager.closeSession()
            state = .disconnected
        default:
            ending = saidGoodbye ? .opponentGaveUp(name: name) : .connectionLost(name: name)
            sessionManager.closeSession()
            state = .disconnected
        }
    }
}

// MARK: - Helpers
private extension LocalMultiplayerCoordinator {
    func beginCountdown() {
        countdownTask?.cancel()
        state = .countdown(remaining: 3)
        countdownTask = Task { [weak self] in
            for count in stride(from: 2, through: 0, by: -1) {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                self?.state = .countdown(remaining: count)
            }
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            self?.currentIndex = 0
            self?.state = .playing
            self?.startQuestionTimer()
        }
    }

    func advanceAfterDelay() {
        guard !isAdvancing else { return }
        isAdvancing = true
        advanceTask?.cancel()
        advanceTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled, let self else { return }
            let next = self.currentIndex + 1
            if next < self.questions.count {
                self.sessionManager.send(.advanceToNext(questionIndex: next))
                self.advanceTo(next)
            } else {
                self.sessionManager.send(.matchFinished(hostScore: self.playerScore, guestScore: self.opponentScore))
                self.state = .finished
            }
        }
    }

    func advanceTo(_ index: Int) {
        guard index < questions.count else {
            state = .finished
            return
        }
        currentIndex = index
        opponentHasAnswered = false
        playerAnsweredCurrent = false
        isAdvancing = false
        questionTimerExpired = false
        startQuestionTimer()
    }

    func startQuestionTimer() {
        questionTimerTask?.cancel()
        guard activeGame == .quiz else { return }
        guard activeDifficulty.hasTimer else { return }
        let duration = activeDifficulty.timerDuration
        questionTimerTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            self?.skipTimedOut()
        }
    }

    func cancelAllTasks() {
        countdownTask?.cancel()
        countdownTask = nil
        advanceTask?.cancel()
        advanceTask = nil
        startTask?.cancel()
        startTask = nil
        questionTimerTask?.cancel()
        questionTimerTask = nil
    }

    func resetForRematch() {
        cancelAllTasks()
        resetMatchState()
        opponent?.isReady = false
        state = .lobby
        shareSettings()
    }

    func shareSettings() {
        guard isHost, state == .lobby else { return }
        sessionManager.send(.lobbySettings(config: currentConfig))
    }

    var currentConfig: PeerMessage.MatchConfig {
        PeerMessage.MatchConfig(
            game: game,
            pinDrop: pinDropConfiguration,
            quizType: quizType,
            region: region,
            difficulty: difficulty,
            questionCount: questionCount.rawValue,
            comparisonMetric: comparisonMetric,
            mapPuzzleContinent: mapPuzzleContinent,
            mapPuzzleQuestionCount: mapPuzzleQuestionCount,
            wordSearchTheme: wordSearchTheme
        )
    }

    func resetMatchState() {
        currentIndex = 0
        playerScore = 0
        opponentScore = 0
        opponentHasAnswered = false
        playerAnsweredCurrent = false
        isAdvancing = false
        questionTimerExpired = false
        playerAnswers = [:]
        opponentAnswers = [:]
        questions = []
        xpAwarded = false
        isReady = false
        gameSetup = nil
        opponentScoredRounds = []
        hasFinishedRounds = false
        opponentHasFinishedRounds = false
        rematchRequested = false
        isAwaitingRematch = false
        rematchDeclined = false
        opponentLeftAfterMatch = false
    }
}
// MARK: - Games Other Than a Quiz
extension LocalMultiplayerCoordinator: LocalMatch {
    var opponentName: String {
        opponent?.displayName ?? String(localized: "Opponent", bundle: .module)
    }

    func hasOpponentScored(round: Int) -> Bool {
        opponentScoredRounds.contains(round)
    }

    func didScore(round: Int, points: Int) {
        guard state == .playing else { return }
        playerScore += points
        sessionManager.send(.roundScored(round: round, points: points))
    }

    func didFinishRounds() {
        guard state == .playing, !hasFinishedRounds else { return }
        hasFinishedRounds = true
        sessionManager.send(.finishedRounds)
        finishIfDone()
    }

    /// The countries to find in Pin Drop, in order.
    var pinDropCountryCodes: [String] {
        guard case .pinDrop(let codes) = gameSetup else { return [] }
        return codes
    }

    var mapPuzzleRounds: [MapPuzzleRound] {
        guard case .mapPuzzle(let rounds) = gameSetup else { return [] }
        return rounds
    }

    /// Every country a Speed Run in the match's region asks for.
    var speedRunCountryCount: Int {
        activeRegion.filter(countryDataService.countries).count
    }

    var wordSearchPuzzle: WordSearchPuzzle? {
        guard case .wordSearch(let puzzle) = gameSetup else { return nil }
        return puzzle
    }
}

private extension LocalMultiplayerCoordinator {
    /// Sends what the host picked and starts the countdown on both phones.
    func start(_ setup: LocalGameSetup) {
        gameSetup = setup
        matchConfig = currentConfig
        sessionManager.send(.startGame(config: currentConfig, setup: setup))
        beginCountdown()
    }

    /// Picks the countries once the map's shapes are loaded, the same way a solo game does.
    func startPinDropMatch() {
        startTask?.cancel()
        startTask = Task { [weak self] in
            guard let self else { return }
            let shapes = await geoJSONCache.loadShapes()
            guard !Task.isCancelled, state == .lobby else { return }
            var generator = SystemRandomNumberGenerator()
            let rounds = PinDropGame.makeRounds(
                for: pinDropConfiguration,
                countries: countryDataService.countries,
                shapes: shapes,
                using: &generator
            )
            guard !rounds.isEmpty else { return }
            start(.pinDrop(countryCodes: rounds.map(\.country.code)))
        }
    }

    /// Asks only about countries drawn on the puzzle's map, as a solo puzzle does.
    func startMapPuzzleMatch() {
        startTask?.cancel()
        startTask = Task { [weak self] in
            guard let self else { return }
            let shapes = await geoJSONCache.loadShapes()
            let outline = await ContinentOutline.puzzleOutline(for: mapPuzzleContinent, shapes: shapes)
            guard !Task.isCancelled, state == .lobby, let outline else { return }
            let mappedCodes = Set(outline.countryPaths.keys)
            let countries = countryDataService.countries.filter { country in
                mappedCodes.contains(country.code) && (mapPuzzleContinent.map { country.continent == $0 } ?? true)
            }
            let rounds = MapPuzzleRules.makeRounds(from: countries, requested: mapPuzzleQuestionCount)
            guard !rounds.isEmpty else { return }
            start(.mapPuzzle(rounds: rounds))
        }
    }

    /// A race ends as soon as either player finishes; the other games once both have.
    func finishIfDone() {
        guard activeGame != .quiz else { return }
        let isDone = activeGame.isRace
            ? hasFinishedRounds || opponentHasFinishedRounds
            : hasFinishedRounds && opponentHasFinishedRounds
        if isDone {
            state = .finished
        }
    }
}
#endif
