import Foundation

public enum XPSource: String, Sendable {
    /// The bonus for the first thing learned each day. Stored as `dailyLogin`, from when opening the app earned it.
    case dailyBonus = "dailyLogin"
    case quizCompletedEasy
    case quizCompletedMedium
    case quizCompletedHard
    case countryExplored
    case travelVisited
    case travelWantToVisit
    case achievementUnlocked
    case streakMilestone7
    case streakMilestone30
    case streakMilestone100
    case speedRunCompleted
    case dailyChallengeCompleted
    case pinDropCompleted
    case mapPuzzleCompleted
    case flashcardSession
    case lessonCompleted
    case wordSearchCompleted

    /// Whether earning XP this way means something was learned, which keeps the streak going. Exploring, travel,
    /// achievements, and bonuses don't count: a streak is for days of practice.
    public var countsAsLearning: Bool {
        switch self {
        case .quizCompletedEasy, .quizCompletedMedium, .quizCompletedHard, .speedRunCompleted,
             .dailyChallengeCompleted, .pinDropCompleted, .mapPuzzleCompleted, .flashcardSession,
             .lessonCompleted, .wordSearchCompleted:
            true
        case .dailyBonus, .countryExplored, .travelVisited, .travelWantToVisit, .achievementUnlocked,
             .streakMilestone7, .streakMilestone30, .streakMilestone100:
            false
        }
    }
}
