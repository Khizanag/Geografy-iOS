import Foundation

public struct SpacedRepetitionData: Codable {
    public var easeFactor: Double
    public var interval: Double
    public var repetitions: Int
    public var nextReviewDate: Date
    public var lastReviewDate: Date?
    public var totalReviews: Int
    public var correctReviews: Int

    public var masteryPercentage: Double {
        guard totalReviews > 0 else { return 0 }
        return Double(correctReviews) / Double(totalReviews)
    }

    public var isDueForReview: Bool {
        nextReviewDate <= Date()
    }

    public var masteryLevel: MasteryLevel {
        if totalReviews == 0 { return .new }
        if repetitions >= 5, easeFactor >= 2.2 { return .mastered }
        if repetitions >= 3 { return .familiar }
        return .learning
    }
}

// MARK: - Mastery Level
extension SpacedRepetitionData {
    public enum MasteryLevel: String, Codable {
        case new
        case learning
        case familiar
        case mastered

        var displayName: String {
            switch self {
            case .new: "New"
            case .learning: "Learning"
            case .familiar: "Familiar"
            case .mastered: "Mastered"
            }
        }
    }
}

// MARK: - Factory
extension SpacedRepetitionData {
    public static func makeNew() -> SpacedRepetitionData {
        SpacedRepetitionData(
            easeFactor: 2.5,
            interval: 0,
            repetitions: 0,
            nextReviewDate: Date(),
            lastReviewDate: nil,
            totalReviews: 0,
            correctReviews: 0,
        )
    }
}

// MARK: - SM-2 Algorithm
extension SpacedRepetitionData {
    public func updated(with result: FlashcardReviewResult) -> SpacedRepetitionData {
        var updated = self
        updated.totalReviews += 1
        updated.lastReviewDate = Date()

        switch result {
        case .again:
            updated.repetitions = 0
            updated.interval = 1
            updated.easeFactor = max(1.3, easeFactor - 0.2)
        case .hard:
            updated.correctReviews += 1
            updated.repetitions += 1
            updated.easeFactor = max(1.3, easeFactor - 0.15)
            updated.interval = calculateInterval(
                repetitions: updated.repetitions,
                previousInterval: interval,
                easeFactor: updated.easeFactor,
                multiplier: 1.2,
            )
        case .good:
            updated.correctReviews += 1
            updated.repetitions += 1
            updated.interval = calculateInterval(
                repetitions: updated.repetitions,
                previousInterval: interval,
                easeFactor: easeFactor,
                multiplier: easeFactor,
            )
        case .easy:
            updated.correctReviews += 1
            updated.repetitions += 1
            updated.easeFactor = easeFactor + 0.15
            updated.interval = calculateInterval(
                repetitions: updated.repetitions,
                previousInterval: interval,
                easeFactor: updated.easeFactor,
                multiplier: updated.easeFactor * 1.3,
            )
        }

        updated.nextReviewDate = Calendar.current.date(
            byAdding: .day,
            value: max(1, Int(updated.interval.rounded())),
            to: Date()
        ) ?? Date().addingTimeInterval(86400)

        return updated
    }
}

// MARK: - Helpers
private extension SpacedRepetitionData {
    func calculateInterval(
        repetitions: Int,
        previousInterval: Double,
        easeFactor: Double,
        multiplier: Double
    ) -> Double {
        if repetitions <= 1 { return 1 }
        if repetitions == 2 { return 3 }
        return previousInterval * multiplier
    }
}
