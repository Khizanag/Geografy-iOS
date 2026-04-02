import Foundation

public struct PlayerRating: Sendable {
    public let rating: Int
    public let wins: Int
    public let losses: Int
    public let draws: Int
}

// MARK: - Defaults
extension PlayerRating {
    public static let initial = PlayerRating(
        rating: 1_200,
        wins: 0,
        losses: 0,
        draws: 0,
    )
}

// MARK: - Computed Properties
extension PlayerRating {
    public var totalMatches: Int {
        wins + losses + draws
    }

    public var winRate: Double {
        guard totalMatches > 0 else { return 0 }
        return Double(wins) / Double(totalMatches)
    }

    public var rankTitle: String {
        if rating >= 2_000 {
            "Grandmaster"
        } else if rating >= 1_800 {
            "Master"
        } else if rating >= 1_600 {
            "Expert"
        } else if rating >= 1_400 {
            "Advanced"
        } else if rating >= 1_200 {
            "Intermediate"
        } else {
            "Beginner"
        }
    }

    public var rankIcon: String {
        if rating >= 2_000 {
            "crown.fill"
        } else if rating >= 1_800 {
            "star.circle.fill"
        } else if rating >= 1_600 {
            "medal.fill"
        } else if rating >= 1_400 {
            "shield.fill"
        } else if rating >= 1_200 {
            "figure.walk"
        } else {
            "leaf.fill"
        }
    }
}

// MARK: - ELO Calculation
extension PlayerRating {
    public static func calculateRatingChanges(
        playerRating: Int,
        opponentRating: Int,
        playerWon: Bool,
        isDraw: Bool
    ) -> (playerChange: Int, opponentChange: Int) {
        let kFactor: Double = 32
        let expectedPlayer = 1.0 / (1.0 + pow(10, Double(opponentRating - playerRating) / 400))
        let expectedOpponent = 1.0 - expectedPlayer

        let actualPlayer: Double
        let actualOpponent: Double
        if isDraw {
            actualPlayer = 0.5
            actualOpponent = 0.5
        } else if playerWon {
            actualPlayer = 1.0
            actualOpponent = 0.0
        } else {
            actualPlayer = 0.0
            actualOpponent = 1.0
        }

        let playerChange = Int(round(kFactor * (actualPlayer - expectedPlayer)))
        let opponentChange = Int(round(kFactor * (actualOpponent - expectedOpponent)))

        return (playerChange, opponentChange)
    }

    public func applying(change: Int, won: Bool, drew: Bool) -> PlayerRating {
        PlayerRating(
            rating: max(100, rating + change),
            wins: wins + (won ? 1 : 0),
            losses: losses + (!won && !drew ? 1 : 0),
            draws: draws + (drew ? 1 : 0),
        )
    }
}
