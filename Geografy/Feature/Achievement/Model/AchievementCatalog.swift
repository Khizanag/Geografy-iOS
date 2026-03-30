import Foundation

enum AchievementCatalog {
    static let all: [AchievementDefinition] =
        explorer + quizMaster + streak + travel + knowledge
        + continental + flashcard + speed + perfectScore + social
}

// MARK: - Explorer
private extension AchievementCatalog {
    static let explorer: [AchievementDefinition] = [
        AchievementDefinition(
            id: "explorer_5", title: "Curious Wanderer",
            description: "Explore 5 countries on the map",
            category: .explorer, rarity: .common, iconName: "figure.walk",
            requirement: "Explore 5 countries", targetValue: 5,
            xpReward: 25, gameCenterID: "geografy.achievement.first_steps"
        ),
        AchievementDefinition(
            id: "explorer_10", title: "Continental Explorer",
            description: "Explore 10 countries",
            category: .explorer, rarity: .common, iconName: "globe.europe.africa",
            requirement: "Explore 10 countries", targetValue: 10,
            xpReward: 50, gameCenterID: "geografy.achievement.continental_explorer"
        ),
        AchievementDefinition(
            id: "explorer_50", title: "World Traveler",
            description: "Explore 50 countries",
            category: .explorer, rarity: .rare, iconName: "globe",
            requirement: "Explore 50 countries", targetValue: 50,
            xpReward: 100, gameCenterID: "geografy.achievement.world_traveler"
        ),
        AchievementDefinition(
            id: "explorer_100", title: "Globe Trotter",
            description: "Explore 100 countries",
            category: .explorer, rarity: .epic, iconName: "globe.americas",
            requirement: "Explore 100 countries", targetValue: 100,
            xpReward: 150, gameCenterID: "geografy.achievement.globe_trotter"
        ),
        AchievementDefinition(
            id: "explorer_195", title: "Master Explorer",
            description: "Explore all 195 countries",
            category: .explorer, rarity: .legendary, iconName: "star.circle.fill",
            requirement: "Explore all 195 countries", targetValue: 195,
            xpReward: 200, gameCenterID: "geografy.achievement.master_explorer"
        ),
    ]
}

// MARK: - Quiz Master
private extension AchievementCatalog {
    static let quizMaster: [AchievementDefinition] = [
        AchievementDefinition(
            id: "quiz_1", title: "First Quiz",
            description: "Complete your first quiz",
            category: .quizMaster, rarity: .common, iconName: "gamecontroller.fill",
            requirement: "Complete 1 quiz", targetValue: 1,
            xpReward: 25, gameCenterID: "geografy.achievement.first_quiz"
        ),
        AchievementDefinition(
            id: "quiz_10", title: "Quiz Fanatic",
            description: "Complete 10 quizzes",
            category: .quizMaster, rarity: .rare, iconName: "brain.fill",
            requirement: "Complete 10 quizzes", targetValue: 10,
            xpReward: 50, gameCenterID: "geografy.achievement.quiz_fanatic"
        ),
        AchievementDefinition(
            id: "quiz_50", title: "Quiz Veteran",
            description: "Complete 50 quizzes",
            category: .quizMaster, rarity: .epic, iconName: "brain.head.profile.fill",
            requirement: "Complete 50 quizzes", targetValue: 50,
            xpReward: 100
        ),
        AchievementDefinition(
            id: "quiz_100", title: "Quiz Legend",
            description: "Complete 100 quizzes",
            category: .quizMaster, rarity: .legendary, iconName: "trophy.fill",
            requirement: "Complete 100 quizzes", targetValue: 100,
            xpReward: 150, gameCenterID: "geografy.achievement.quiz_legend"
        ),
        AchievementDefinition(
            id: "all_types", title: "Polymath",
            description: "Complete all quiz types at least once",
            category: .quizMaster, rarity: .epic, iconName: "square.grid.2x2.fill",
            requirement: "Try every quiz type", targetValue: 6,
            xpReward: 75, gameCenterID: "geografy.achievement.all_types"
        ),
    ]
}

// MARK: - Streak
private extension AchievementCatalog {
    static let streak: [AchievementDefinition] = [
        AchievementDefinition(
            id: "streak_3", title: "Getting Started",
            description: "Log in 3 days in a row",
            category: .streak, rarity: .common, iconName: "flame",
            requirement: "3-day streak", targetValue: 3,
            xpReward: 25, gameCenterID: "geografy.achievement.getting_started"
        ),
        AchievementDefinition(
            id: "streak_7", title: "Week Warrior",
            description: "Log in 7 days in a row",
            category: .streak, rarity: .rare, iconName: "flame.fill",
            requirement: "7-day streak", targetValue: 7,
            xpReward: 50, gameCenterID: "geografy.achievement.week_warrior"
        ),
        AchievementDefinition(
            id: "streak_30", title: "Monthly Champion",
            description: "Log in 30 days in a row",
            category: .streak, rarity: .epic, iconName: "calendar.badge.checkmark",
            requirement: "30-day streak", targetValue: 30,
            xpReward: 150, gameCenterID: "geografy.achievement.monthly_champion"
        ),
        AchievementDefinition(
            id: "streak_100", title: "Dedicated Scholar",
            description: "Log in 100 days in a row",
            category: .streak, rarity: .legendary, iconName: "medal.fill",
            requirement: "100-day streak", targetValue: 100,
            xpReward: 200, gameCenterID: "geografy.achievement.dedicated_scholar",
            isSecret: true
        ),
    ]
}

// MARK: - Travel
private extension AchievementCatalog {
    static let travel: [AchievementDefinition] = [
        AchievementDefinition(
            id: "travel_1", title: "First Stamp",
            description: "Mark your first visited country",
            category: .travel, rarity: .common, iconName: "airplane.departure",
            requirement: "Visit 1 country", targetValue: 1,
            xpReward: 25, gameCenterID: "geografy.achievement.first_stamp"
        ),
        AchievementDefinition(
            id: "travel_10", title: "Frequent Flyer",
            description: "Visit 10 countries",
            category: .travel, rarity: .rare, iconName: "airplane",
            requirement: "Visit 10 countries", targetValue: 10,
            xpReward: 75, gameCenterID: "geografy.achievement.frequent_flyer"
        ),
        AchievementDefinition(
            id: "travel_50", title: "World Adventurer",
            description: "Visit 50 countries",
            category: .travel, rarity: .epic, iconName: "map.fill",
            requirement: "Visit 50 countries", targetValue: 50,
            xpReward: 150, gameCenterID: "geografy.achievement.world_adventurer"
        ),
        AchievementDefinition(
            id: "bucket_5", title: "Bucket List",
            description: "Add 5 want-to-visit countries",
            category: .travel, rarity: .common, iconName: "list.star",
            requirement: "5 bucket list countries", targetValue: 5,
            xpReward: 50, gameCenterID: "geografy.achievement.bucket_list"
        ),
    ]
}

// MARK: - Knowledge
private extension AchievementCatalog {
    static let knowledge: [AchievementDefinition] = [
        AchievementDefinition(
            id: "flag_5", title: "Flag Collector",
            description: "Complete 5 flag quizzes",
            category: .knowledge, rarity: .common, iconName: "flag.fill",
            requirement: "Complete 5 flag quizzes", targetValue: 5,
            xpReward: 50, gameCenterID: "geografy.achievement.flag_collector"
        ),
        AchievementDefinition(
            id: "capital_5", title: "Capital Expert",
            description: "Complete 5 capital quizzes",
            category: .knowledge, rarity: .common, iconName: "building.columns.fill",
            requirement: "Complete 5 capital quizzes", targetValue: 5,
            xpReward: 50, gameCenterID: "geografy.achievement.capital_expert"
        ),
        AchievementDefinition(
            id: "org_all", title: "Org Scholar",
            description: "Explore all organizations",
            category: .knowledge, rarity: .rare, iconName: "building.2.fill",
            requirement: "Open all organizations", targetValue: 16,
            xpReward: 75, gameCenterID: "geografy.achievement.org_scholar"
        ),
    ]
}

// MARK: - Continental
private extension AchievementCatalog {
    static let continental: [AchievementDefinition] = [
        AchievementDefinition(
            id: "continent_europe", title: "European Explorer",
            description: "Explore all European countries",
            category: .continental, rarity: .rare, iconName: "globe.europe.africa",
            requirement: "Explore all of Europe", targetValue: 1
        ),
        AchievementDefinition(
            id: "continent_asia", title: "Asian Explorer",
            description: "Explore all Asian countries",
            category: .continental, rarity: .rare, iconName: "globe.asia.australia",
            requirement: "Explore all of Asia", targetValue: 1
        ),
        AchievementDefinition(
            id: "continent_africa", title: "African Explorer",
            description: "Explore all African countries",
            category: .continental, rarity: .epic, iconName: "globe.europe.africa",
            requirement: "Explore all of Africa", targetValue: 1
        ),
        AchievementDefinition(
            id: "continent_americas", title: "Americas Explorer",
            description: "Explore all countries in the Americas",
            category: .continental, rarity: .epic, iconName: "globe.americas",
            requirement: "Explore all of the Americas", targetValue: 1
        ),
        AchievementDefinition(
            id: "continent_oceania", title: "Oceania Explorer",
            description: "Explore all Oceanian countries",
            category: .continental, rarity: .rare, iconName: "globe.asia.australia",
            requirement: "Explore all of Oceania", targetValue: 1
        ),
        AchievementDefinition(
            id: "all_continents", title: "Global Citizen",
            description: "Explore countries on every continent",
            category: .continental, rarity: .legendary, iconName: "globe.desk.fill",
            requirement: "Visit all continents", targetValue: 6
        ),
    ]
}

// MARK: - Flashcard
private extension AchievementCatalog {
    static let flashcard: [AchievementDefinition] = [
        AchievementDefinition(
            id: "flashcard_10", title: "Study Buddy",
            description: "Master 10 flashcards",
            category: .flashcard, rarity: .common, iconName: "rectangle.on.rectangle.angled",
            requirement: "Master 10 flashcards", targetValue: 10
        ),
        AchievementDefinition(
            id: "flashcard_50", title: "Flashcard Scholar",
            description: "Master 50 flashcards",
            category: .flashcard, rarity: .rare, iconName: "graduationcap.fill",
            requirement: "Master 50 flashcards", targetValue: 50
        ),
        AchievementDefinition(
            id: "flashcard_200", title: "Memory Champion",
            description: "Master 200 flashcards",
            category: .flashcard, rarity: .legendary, iconName: "brain.fill",
            requirement: "Master 200 flashcards", targetValue: 200
        ),
    ]
}

// MARK: - Speed
private extension AchievementCatalog {
    static let speed: [AchievementDefinition] = [
        AchievementDefinition(
            id: "speed_60", title: "Speed Demon",
            description: "Finish a Hard quiz in under 60 seconds",
            category: .speed, rarity: .epic, iconName: "bolt.fill",
            requirement: "Hard quiz under 60s", targetValue: 1,
            xpReward: 100, gameCenterID: "geografy.achievement.speed_demon",
            isSecret: true
        ),
        AchievementDefinition(
            id: "speed_run_world", title: "Speed Runner",
            description: "Complete a World Speed Run",
            category: .speed, rarity: .rare, iconName: "timer",
            requirement: "Finish World Speed Run", targetValue: 1
        ),
    ]
}

// MARK: - Perfect Score
private extension AchievementCatalog {
    static let perfectScore: [AchievementDefinition] = [
        AchievementDefinition(
            id: "perfect_1", title: "Flawless",
            description: "Get 100% on any quiz",
            category: .perfectScore, rarity: .rare, iconName: "checkmark.seal.fill",
            requirement: "100% on a quiz", targetValue: 1,
            xpReward: 75, gameCenterID: "geografy.achievement.perfect_score"
        ),
        AchievementDefinition(
            id: "perfect_5", title: "Perfectionist",
            description: "Get 100% on 5 quizzes",
            category: .perfectScore, rarity: .epic, iconName: "seal.fill",
            requirement: "5 perfect quizzes", targetValue: 5
        ),
        AchievementDefinition(
            id: "perfect_20", title: "Infallible",
            description: "Get 100% on 20 quizzes",
            category: .perfectScore, rarity: .legendary, iconName: "star.seal.fill",
            requirement: "20 perfect quizzes", targetValue: 20
        ),
    ]
}

// MARK: - Social
private extension AchievementCatalog {
    static let social: [AchievementDefinition] = [
        AchievementDefinition(
            id: "share_1", title: "Show Off",
            description: "Share a result for the first time",
            category: .social, rarity: .common, iconName: "square.and.arrow.up",
            requirement: "Share 1 result", targetValue: 1
        ),
        AchievementDefinition(
            id: "share_10", title: "Social Butterfly",
            description: "Share 10 results with friends",
            category: .social, rarity: .rare, iconName: "person.2.fill",
            requirement: "Share 10 results", targetValue: 10
        ),
    ]
}
