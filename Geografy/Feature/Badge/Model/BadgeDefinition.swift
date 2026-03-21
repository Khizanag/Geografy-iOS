import Foundation

struct BadgeDefinition: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let category: BadgeCategory
    let rarity: BadgeRarity
    let iconName: String
    let requirement: String
    let targetValue: Int
}

// MARK: - Badge Catalog

extension BadgeDefinition {
    static let all: [BadgeDefinition] = explorer
        + quizMaster
        + streakWarrior
        + continentalExpert
        + flashcardScholar
        + speedDemon
        + perfectScore
        + earlyBird
        + nightOwl
        + socialButterfly
}

// MARK: - Explorer

private extension BadgeDefinition {
    static let explorer: [BadgeDefinition] = [
        BadgeDefinition(
            id: "badge_explorer_5",
            title: "Curious Wanderer",
            description: "Explore 5 countries on the map",
            category: .explorer,
            rarity: .common,
            iconName: "figure.walk",
            requirement: "Explore 5 countries",
            targetValue: 5
        ),
        BadgeDefinition(
            id: "badge_explorer_10",
            title: "Seasoned Traveler",
            description: "Explore 10 countries on the map",
            category: .explorer,
            rarity: .common,
            iconName: "globe.europe.africa",
            requirement: "Explore 10 countries",
            targetValue: 10
        ),
        BadgeDefinition(
            id: "badge_explorer_25",
            title: "World Wanderer",
            description: "Explore 25 countries on the map",
            category: .explorer,
            rarity: .rare,
            iconName: "globe.americas",
            requirement: "Explore 25 countries",
            targetValue: 25
        ),
        BadgeDefinition(
            id: "badge_explorer_50",
            title: "Globe Trotter",
            description: "Explore 50 countries on the map",
            category: .explorer,
            rarity: .rare,
            iconName: "globe",
            requirement: "Explore 50 countries",
            targetValue: 50
        ),
        BadgeDefinition(
            id: "badge_explorer_100",
            title: "Cartographer",
            description: "Explore 100 countries on the map",
            category: .explorer,
            rarity: .epic,
            iconName: "map.fill",
            requirement: "Explore 100 countries",
            targetValue: 100
        ),
        BadgeDefinition(
            id: "badge_explorer_197",
            title: "Master Explorer",
            description: "Explore every country in the world",
            category: .explorer,
            rarity: .legendary,
            iconName: "star.circle.fill",
            requirement: "Explore all 197 countries",
            targetValue: 197
        ),
    ]
}

// MARK: - Quiz Master

private extension BadgeDefinition {
    static let quizMaster: [BadgeDefinition] = [
        BadgeDefinition(
            id: "badge_quiz_10",
            title: "Quiz Novice",
            description: "Complete 10 quizzes",
            category: .quizMaster,
            rarity: .common,
            iconName: "gamecontroller.fill",
            requirement: "Complete 10 quizzes",
            targetValue: 10
        ),
        BadgeDefinition(
            id: "badge_quiz_50",
            title: "Quiz Enthusiast",
            description: "Complete 50 quizzes",
            category: .quizMaster,
            rarity: .rare,
            iconName: "brain.fill",
            requirement: "Complete 50 quizzes",
            targetValue: 50
        ),
        BadgeDefinition(
            id: "badge_quiz_100",
            title: "Quiz Champion",
            description: "Complete 100 quizzes",
            category: .quizMaster,
            rarity: .epic,
            iconName: "trophy.fill",
            requirement: "Complete 100 quizzes",
            targetValue: 100
        ),
        BadgeDefinition(
            id: "badge_quiz_500",
            title: "Quiz Legend",
            description: "Complete 500 quizzes",
            category: .quizMaster,
            rarity: .legendary,
            iconName: "crown.fill",
            requirement: "Complete 500 quizzes",
            targetValue: 500
        ),
    ]
}

// MARK: - Streak Warrior

private extension BadgeDefinition {
    static let streakWarrior: [BadgeDefinition] = [
        BadgeDefinition(
            id: "badge_streak_7",
            title: "Week Warrior",
            description: "Maintain a 7-day streak",
            category: .streakWarrior,
            rarity: .common,
            iconName: "flame",
            requirement: "7-day streak",
            targetValue: 7
        ),
        BadgeDefinition(
            id: "badge_streak_30",
            title: "Monthly Marathoner",
            description: "Maintain a 30-day streak",
            category: .streakWarrior,
            rarity: .rare,
            iconName: "flame.fill",
            requirement: "30-day streak",
            targetValue: 30
        ),
        BadgeDefinition(
            id: "badge_streak_100",
            title: "Century Streak",
            description: "Maintain a 100-day streak",
            category: .streakWarrior,
            rarity: .epic,
            iconName: "flame.circle.fill",
            requirement: "100-day streak",
            targetValue: 100
        ),
        BadgeDefinition(
            id: "badge_streak_365",
            title: "Year of Dedication",
            description: "Maintain a 365-day streak",
            category: .streakWarrior,
            rarity: .legendary,
            iconName: "calendar.badge.checkmark",
            requirement: "365-day streak",
            targetValue: 365
        ),
    ]
}

// MARK: - Continental Expert

private extension BadgeDefinition {
    static let continentalExpert: [BadgeDefinition] = [
        BadgeDefinition(
            id: "badge_continent_africa",
            title: "Africa Expert",
            description: "Master all countries in Africa",
            category: .continentalExpert,
            rarity: .epic,
            iconName: "globe.europe.africa",
            requirement: "Master all African countries",
            targetValue: 1
        ),
        BadgeDefinition(
            id: "badge_continent_asia",
            title: "Asia Expert",
            description: "Master all countries in Asia",
            category: .continentalExpert,
            rarity: .epic,
            iconName: "globe.asia.australia",
            requirement: "Master all Asian countries",
            targetValue: 1
        ),
        BadgeDefinition(
            id: "badge_continent_europe",
            title: "Europe Expert",
            description: "Master all countries in Europe",
            category: .continentalExpert,
            rarity: .epic,
            iconName: "globe.europe.africa",
            requirement: "Master all European countries",
            targetValue: 1
        ),
        BadgeDefinition(
            id: "badge_continent_namerica",
            title: "North America Expert",
            description: "Master all countries in North America",
            category: .continentalExpert,
            rarity: .epic,
            iconName: "globe.americas",
            requirement: "Master all N. American countries",
            targetValue: 1
        ),
        BadgeDefinition(
            id: "badge_continent_samerica",
            title: "South America Expert",
            description: "Master all countries in South America",
            category: .continentalExpert,
            rarity: .epic,
            iconName: "globe.americas",
            requirement: "Master all S. American countries",
            targetValue: 1
        ),
        BadgeDefinition(
            id: "badge_continent_oceania",
            title: "Oceania Expert",
            description: "Master all countries in Oceania",
            category: .continentalExpert,
            rarity: .epic,
            iconName: "globe.asia.australia",
            requirement: "Master all Oceanian countries",
            targetValue: 1
        ),
        BadgeDefinition(
            id: "badge_continent_antarctica",
            title: "Antarctica Scholar",
            description: "Learn about all Antarctic territories",
            category: .continentalExpert,
            rarity: .rare,
            iconName: "snowflake",
            requirement: "Learn Antarctic territories",
            targetValue: 1
        ),
    ]
}

// MARK: - Flashcard Scholar

private extension BadgeDefinition {
    static let flashcardScholar: [BadgeDefinition] = [
        BadgeDefinition(
            id: "badge_flashcard_25",
            title: "Card Starter",
            description: "Master 25 flashcards",
            category: .flashcardScholar,
            rarity: .common,
            iconName: "rectangle.on.rectangle",
            requirement: "Master 25 flashcards",
            targetValue: 25
        ),
        BadgeDefinition(
            id: "badge_flashcard_50",
            title: "Card Collector",
            description: "Master 50 flashcards",
            category: .flashcardScholar,
            rarity: .rare,
            iconName: "rectangle.on.rectangle.angled",
            requirement: "Master 50 flashcards",
            targetValue: 50
        ),
        BadgeDefinition(
            id: "badge_flashcard_100",
            title: "Card Master",
            description: "Master 100 flashcards",
            category: .flashcardScholar,
            rarity: .epic,
            iconName: "rectangle.stack.fill",
            requirement: "Master 100 flashcards",
            targetValue: 100
        ),
        BadgeDefinition(
            id: "badge_flashcard_all",
            title: "Total Recall",
            description: "Master every flashcard in the deck",
            category: .flashcardScholar,
            rarity: .legendary,
            iconName: "sparkles.rectangle.stack.fill",
            requirement: "Master all flashcards",
            targetValue: 999
        ),
    ]
}

// MARK: - Speed Demon

private extension BadgeDefinition {
    static let speedDemon: [BadgeDefinition] = [
        BadgeDefinition(
            id: "badge_speed_60",
            title: "Quick Thinker",
            description: "Complete a quiz in under 60 seconds",
            category: .speedDemon,
            rarity: .rare,
            iconName: "bolt.fill",
            requirement: "Complete quiz under 60s",
            targetValue: 60
        ),
        BadgeDefinition(
            id: "badge_speed_30",
            title: "Lightning Fast",
            description: "Complete a quiz in under 30 seconds",
            category: .speedDemon,
            rarity: .epic,
            iconName: "bolt.circle.fill",
            requirement: "Complete quiz under 30s",
            targetValue: 30
        ),
        BadgeDefinition(
            id: "badge_speed_15",
            title: "Speed of Light",
            description: "Complete a quiz in under 15 seconds",
            category: .speedDemon,
            rarity: .legendary,
            iconName: "bolt.trianglebadge.exclamationmark.fill",
            requirement: "Complete quiz under 15s",
            targetValue: 15
        ),
    ]
}

// MARK: - Perfect Score

private extension BadgeDefinition {
    static let perfectScore: [BadgeDefinition] = [
        BadgeDefinition(
            id: "badge_perfect_1",
            title: "Flawless",
            description: "Get 100% accuracy on any quiz",
            category: .perfectScore,
            rarity: .rare,
            iconName: "checkmark.seal.fill",
            requirement: "100% on 1 quiz",
            targetValue: 1
        ),
        BadgeDefinition(
            id: "badge_perfect_5",
            title: "Perfectionist",
            description: "Get 100% accuracy on 5 quizzes",
            category: .perfectScore,
            rarity: .epic,
            iconName: "star.fill",
            requirement: "100% on 5 quizzes",
            targetValue: 5
        ),
        BadgeDefinition(
            id: "badge_perfect_25",
            title: "Untouchable",
            description: "Get 100% accuracy on 25 quizzes",
            category: .perfectScore,
            rarity: .legendary,
            iconName: "crown.fill",
            requirement: "100% on 25 quizzes",
            targetValue: 25
        ),
    ]
}

// MARK: - Early Bird

private extension BadgeDefinition {
    static let earlyBird: [BadgeDefinition] = [
        BadgeDefinition(
            id: "badge_earlybird_1",
            title: "Dawn Riser",
            description: "Complete a challenge before 8 AM",
            category: .earlyBird,
            rarity: .rare,
            iconName: "sunrise.fill",
            requirement: "Complete challenge before 8 AM",
            targetValue: 1
        ),
        BadgeDefinition(
            id: "badge_earlybird_10",
            title: "Morning Champion",
            description: "Complete 10 challenges before 8 AM",
            category: .earlyBird,
            rarity: .epic,
            iconName: "sun.and.horizon.fill",
            requirement: "10 challenges before 8 AM",
            targetValue: 10
        ),
    ]
}

// MARK: - Night Owl

private extension BadgeDefinition {
    static let nightOwl: [BadgeDefinition] = [
        BadgeDefinition(
            id: "badge_nightowl_1",
            title: "Night Scholar",
            description: "Complete a challenge after 10 PM",
            category: .nightOwl,
            rarity: .rare,
            iconName: "moon.stars.fill",
            requirement: "Complete challenge after 10 PM",
            targetValue: 1
        ),
        BadgeDefinition(
            id: "badge_nightowl_10",
            title: "Midnight Master",
            description: "Complete 10 challenges after 10 PM",
            category: .nightOwl,
            rarity: .epic,
            iconName: "moon.circle.fill",
            requirement: "10 challenges after 10 PM",
            targetValue: 10
        ),
    ]
}

// MARK: - Social Butterfly

private extension BadgeDefinition {
    static let socialButterfly: [BadgeDefinition] = [
        BadgeDefinition(
            id: "badge_social_5",
            title: "Social Butterfly",
            description: "Share your quiz results 5 times",
            category: .socialButterfly,
            rarity: .rare,
            iconName: "person.2.fill",
            requirement: "Share results 5 times",
            targetValue: 5
        ),
        BadgeDefinition(
            id: "badge_social_25",
            title: "Community Star",
            description: "Share your quiz results 25 times",
            category: .socialButterfly,
            rarity: .epic,
            iconName: "person.3.fill",
            requirement: "Share results 25 times",
            targetValue: 25
        ),
    ]
}
