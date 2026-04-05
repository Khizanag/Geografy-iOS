import Geografy_Core_Common
#if !os(tvOS)
import Geografy_Core_Service
import Geografy_Feature_Quiz
import MultipeerConnectivity
import SwiftUI

@MainActor
@Observable
public final class LocalMultiplayerCoordinator {
    public let sessionManager = MultipeerSessionManager()

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
    public var rematchRequested = false
    private(set) var questionTimerExpired = false

    public var quizType: QuizType = .flagQuiz
    public var region: QuizRegion = .world
    public var difficulty: QuizDifficulty = .easy
    public var questionCount: QuestionCount = .ten

    private var countryDataService = CountryDataService()
    private var opponentAnswers: [Int: (optionID: UUID, timeSpent: TimeInterval)] = [:]
    private var playerAnswers: [Int: (optionID: UUID, timeSpent: TimeInterval)] = [:]
    private var countdownTask: Task<Void, Never>?
    private var advanceTask: Task<Void, Never>?
    private var startTask: Task<Void, Never>?
    private var questionTimerTask: Task<Void, Never>?
    private var isAdvancing = false
    private var xpAwarded = false

    public init() {
        Task { await countryDataService.loadCountries() }
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
        state = .advertising
        sessionManager.startAdvertising()
    }

    public func startMatch() {
        guard isHost, opponent?.isReady == true else { return }

        let regionCountries = region.filter(countryDataService.countries)
        let generated = QuestionGenerator.generate(
            type: quizType,
            countries: regionCountries,
            count: questionCount.rawValue,
            optionCount: difficulty.optionCount > 0 ? difficulty.optionCount : 4
        )

        guard !generated.isEmpty else { return }
        questions = generated

        let serialized = generated.map { SerializableQuestion(from: $0) }
        let matchCfg = PeerMessage.MatchConfig(
            quizType: quizType,
            region: region,
            difficulty: difficulty,
            questionCount: questionCount.rawValue
        )

        sessionManager.send(.startMatch(config: matchCfg, questions: serialized))
        beginCountdown()
    }
}

// MARK: - Guest Actions
extension LocalMultiplayerCoordinator {
    public func startBrowsing() {
        isHost = false
        state = .browsing
        sessionManager.startBrowsing()
    }

    public func joinHost(_ peerID: MCPeerID) {
        sessionManager.invitePeer(peerID)
    }

    public func markReady() {
        guard opponent?.isReady != true else { return }
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
        sessionManager.send(.rematchRequest)
    }

    public func acceptRematch() {
        sessionManager.send(.rematchAccepted)
        resetForRematch()
    }

    public func declineRematch() {
        rematchRequested = false
    }

    public func leave() {
        cancelAllTasks()
        sessionManager.disconnect()
        state = .idle
        resetMatchState()
    }
}

// MARK: - Message Handling
private extension LocalMultiplayerCoordinator {
    func handleMessage(_ message: PeerMessage) {
        switch message {
        case .playerInfo(let name): handlePlayerInfo(name)
        case .lobbyReady: handleLobbyReady()
        case let .startMatch(config, serialized): handleStartMatch(config, serialized)
        case let .answerSubmitted(index, optionID, _): handleOpponentAnswer(index, optionID: optionID)
        case .timedOut(let index): handleOpponentTimeout(index)
        case .advanceToNext(let index): handleAdvance(index)
        case let .matchFinished(hostScore, guestScore): handleMatchFinished(hostScore, guestScore)
        case .rematchRequest: rematchRequested = true
        case .rematchAccepted: resetForRematch()
        case .disconnecting: handleDisconnect()
        }
    }

    func handlePlayerInfo(_ name: String) {
        guard state == .lobby || state == .advertising || state == .browsing else { return }
        opponent?.displayName = name
    }

    func handleLobbyReady() {
        guard state == .lobby else { return }
        opponent?.isReady = true
    }

    func handleStartMatch(_ config: PeerMessage.MatchConfig, _ serialized: [SerializableQuestion]) {
        guard state == .lobby else { return }
        matchConfig = config
        questions = serialized.compactMap { $0.toQuizQuestion(using: countryDataService) }
        guard questions.count == serialized.count else {
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
            if opponent == nil {
                opponent = PeerPlayer(peerID: peerID)
                state = .lobby
                sessionManager.send(.playerInfo(name: UIDevice.current.name))
                sessionManager.stopAdvertising()
                sessionManager.stopBrowsing()
            }
        case .notConnected:
            handleDisconnect()
        case .connecting:
            break
        @unknown default:
            break
        }
    }

    func handleDisconnect() {
        guard state != .idle, state != .disconnected else { return }
        cancelAllTasks()
        state = .disconnected
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
        guard difficulty.hasTimer else { return }
        let duration = difficulty.timerDuration
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
        rematchRequested = false
        state = .lobby
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
    }
}
#endif
