import Foundation
import Geografy_Core_Common

@Observable
public final class MultiplayerService {
    private(set) var playerRating = PlayerRating.initial
    private(set) var matchHistory: [MultiplayerMatch] = []

    private let userDefaultsKey = "com.khizanag.geografy.multiplayerRating"

    public init() {
        loadRating()
    }

    /// Reloads the active user's rating; the lobby calls it on appear, so a user switch shows the right one.
    public func reload() {
        loadRating()
    }
}

// MARK: - Match Management
extension MultiplayerService {
    public func recordMatch(
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
        let baseRating = 1_000 + Int(skillLevel * 1_200)
        let jitter = Int.random(in: -100...100)
        return baseRating + jitter
    }

    func loadRating() {
        let defaults = UserDefaults.standard
        // The rating key is the one that's always written, so its presence means a saved rating exists.
        guard defaults.object(forKey: key("rating")) != nil else {
            playerRating = .initial
            return
        }

        let rating = defaults.integer(forKey: key("rating"))
        let wins = defaults.integer(forKey: key("wins"))
        let losses = defaults.integer(forKey: key("losses"))
        let draws = defaults.integer(forKey: key("draws"))

        playerRating = PlayerRating(
            rating: rating,
            wins: wins,
            losses: losses,
            draws: draws,
        )
    }

    func saveRating() {
        let defaults = UserDefaults.standard
        defaults.set(playerRating.rating, forKey: key("rating"))
        defaults.set(playerRating.wins, forKey: key("wins"))
        defaults.set(playerRating.losses, forKey: key("losses"))
        defaults.set(playerRating.draws, forKey: key("draws"))
    }

    func key(_ field: String) -> String {
        UserScope.key("\(userDefaultsKey).\(field)")
    }
}
