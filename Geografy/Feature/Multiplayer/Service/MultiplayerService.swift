import Foundation

@Observable
final class MultiplayerService {
    private(set) var playerRating = PlayerRating.initial
    private(set) var matchHistory: [MultiplayerMatch] = []

    private let userDefaultsKey = "com.khizanag.geografy.multiplayerRating"
    private let historyKey = "com.khizanag.geografy.matchHistory"

    init() {
        loadRating()
    }
}

// MARK: - Match Management
extension MultiplayerService {
    func recordMatch(
        opponent: MockOpponent,
        configuration: QuizConfiguration,
        rounds: [MultiplayerRound]
    ) -> MultiplayerMatch {
        let playerScore = rounds.filter(\.playerWonRound).count
        let opponentScore = rounds.filter(\.opponentWonRound).count
        let playerWon = playerScore > opponentScore
        let isDraw = playerScore == opponentScore

        let opponentRating = makeOpponentRating(skillLevel: opponent.skillLevel)

        let changes = PlayerRating.calculateRatingChanges(
            playerRating: playerRating.rating,
            opponentRating: opponentRating,
            playerWon: playerWon,
            isDraw: isDraw,
        )

        let match = MultiplayerMatch(
            id: UUID(),
            opponent: opponent,
            configuration: configuration,
            rounds: rounds,
            date: Date(),
            playerRatingChange: changes.playerChange,
            opponentRatingChange: changes.opponentChange,
        )

        playerRating = playerRating.applying(
            change: changes.playerChange,
            won: playerWon,
            drew: isDraw,
        )

        matchHistory.insert(match, at: 0)

        saveRating()

        return match
    }
}

// MARK: - Helpers
private extension MultiplayerService {
    func makeOpponentRating(skillLevel: Double) -> Int {
        let baseRating = 1000 + Int(skillLevel * 1200)
        let jitter = Int.random(in: -100...100)
        return baseRating + jitter
    }

    func loadRating() {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: userDefaultsKey) != nil else { return }

        let rating = defaults.integer(forKey: "\(userDefaultsKey).rating")
        let wins = defaults.integer(forKey: "\(userDefaultsKey).wins")
        let losses = defaults.integer(forKey: "\(userDefaultsKey).losses")
        let draws = defaults.integer(forKey: "\(userDefaultsKey).draws")

        playerRating = PlayerRating(
            rating: rating,
            wins: wins,
            losses: losses,
            draws: draws,
        )
    }

    func saveRating() {
        let defaults = UserDefaults.standard
        defaults.set(playerRating.rating, forKey: "\(userDefaultsKey).rating")
        defaults.set(playerRating.wins, forKey: "\(userDefaultsKey).wins")
        defaults.set(playerRating.losses, forKey: "\(userDefaultsKey).losses")
        defaults.set(playerRating.draws, forKey: "\(userDefaultsKey).draws")
    }
}
