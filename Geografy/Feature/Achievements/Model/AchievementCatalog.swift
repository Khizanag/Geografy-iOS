import Foundation

enum AchievementCatalog {
    static let all: [AchievementDefinition] = explorer + quizMaster + travelTracker + streak + knowledge
}

// MARK: - Explorer

private extension AchievementCatalog {
    static let explorer: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_steps",
            title: "First Steps",
            description: "Open your first country",
            category: .explorer,
            xpReward: 25,
            gameCenterID: "geografy.achievement.first_steps",
            iconName: "figure.walk",
            isSecret: false
        ),
        AchievementDefinition(
            id: "continental_explorer",
            title: "Continental Explorer",
            description: "Explore 10 countries",
            category: .explorer,
            xpReward: 50,
            gameCenterID: "geografy.achievement.continental_explorer",
            iconName: "globe.europe.africa",
            isSecret: false
        ),
        AchievementDefinition(
            id: "world_traveler",
            title: "World Traveler",
            description: "Explore 50 countries",
            category: .explorer,
            xpReward: 100,
            gameCenterID: "geografy.achievement.world_traveler",
            iconName: "globe",
            isSecret: false
        ),
        AchievementDefinition(
            id: "globe_trotter",
            title: "Globe Trotter",
            description: "Explore 100 countries",
            category: .explorer,
            xpReward: 150,
            gameCenterID: "geografy.achievement.globe_trotter",
            iconName: "globe.americas",
            isSecret: false
        ),
        AchievementDefinition(
            id: "master_explorer",
            title: "Master Explorer",
            description: "Explore all 195 countries",
            category: .explorer,
            xpReward: 200,
            gameCenterID: "geografy.achievement.master_explorer",
            iconName: "star.circle.fill",
            isSecret: false
        ),
    ]
}

// MARK: - Quiz Master

private extension AchievementCatalog {
    static let quizMaster: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_quiz",
            title: "First Quiz",
            description: "Complete your first quiz",
            category: .quizMaster,
            xpReward: 25,
            gameCenterID: "geografy.achievement.first_quiz",
            iconName: "gamecontroller.fill",
            isSecret: false
        ),
        AchievementDefinition(
            id: "perfect_score",
            title: "Perfect Score",
            description: "Get 100% on any quiz",
            category: .quizMaster,
            xpReward: 75,
            gameCenterID: "geografy.achievement.perfect_score",
            iconName: "checkmark.seal.fill",
            isSecret: false
        ),
        AchievementDefinition(
            id: "quiz_fanatic",
            title: "Quiz Fanatic",
            description: "Complete 10 quizzes",
            category: .quizMaster,
            xpReward: 50,
            gameCenterID: "geografy.achievement.quiz_fanatic",
            iconName: "brain.fill",
            isSecret: false
        ),
        AchievementDefinition(
            id: "quiz_legend",
            title: "Quiz Legend",
            description: "Complete 100 quizzes",
            category: .quizMaster,
            xpReward: 150,
            gameCenterID: "geografy.achievement.quiz_legend",
            iconName: "trophy.fill",
            isSecret: false
        ),
        AchievementDefinition(
            id: "speed_demon",
            title: "Speed Demon",
            description: "Finish a Hard quiz in under 60 seconds",
            category: .quizMaster,
            xpReward: 100,
            gameCenterID: "geografy.achievement.speed_demon",
            iconName: "bolt.fill",
            isSecret: true
        ),
        AchievementDefinition(
            id: "all_types",
            title: "Polymath",
            description: "Complete all 6 quiz types at least once",
            category: .quizMaster,
            xpReward: 75,
            gameCenterID: "geografy.achievement.all_types",
            iconName: "square.grid.2x2.fill",
            isSecret: false
        ),
    ]
}

// MARK: - Travel Tracker

private extension AchievementCatalog {
    static let travelTracker: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_stamp",
            title: "First Stamp",
            description: "Mark your first visited country",
            category: .travelTracker,
            xpReward: 25,
            gameCenterID: "geografy.achievement.first_stamp",
            iconName: "airplane.departure",
            isSecret: false
        ),
        AchievementDefinition(
            id: "frequent_flyer",
            title: "Frequent Flyer",
            description: "Visit 10 countries",
            category: .travelTracker,
            xpReward: 75,
            gameCenterID: "geografy.achievement.frequent_flyer",
            iconName: "airplane",
            isSecret: false
        ),
        AchievementDefinition(
            id: "world_adventurer",
            title: "World Adventurer",
            description: "Visit 50 countries",
            category: .travelTracker,
            xpReward: 150,
            gameCenterID: "geografy.achievement.world_adventurer",
            iconName: "map.fill",
            isSecret: false
        ),
        AchievementDefinition(
            id: "bucket_list",
            title: "Bucket List",
            description: "Add 5 want-to-visit countries",
            category: .travelTracker,
            xpReward: 50,
            gameCenterID: "geografy.achievement.bucket_list",
            iconName: "list.star",
            isSecret: false
        ),
    ]
}

// MARK: - Streak

private extension AchievementCatalog {
    static let streak: [AchievementDefinition] = [
        AchievementDefinition(
            id: "getting_started",
            title: "Getting Started",
            description: "Log in 3 days in a row",
            category: .streak,
            xpReward: 25,
            gameCenterID: "geografy.achievement.getting_started",
            iconName: "flame",
            isSecret: false
        ),
        AchievementDefinition(
            id: "week_warrior",
            title: "Week Warrior",
            description: "Log in 7 days in a row",
            category: .streak,
            xpReward: 50,
            gameCenterID: "geografy.achievement.week_warrior",
            iconName: "flame.fill",
            isSecret: false
        ),
        AchievementDefinition(
            id: "monthly_champion",
            title: "Monthly Champion",
            description: "Log in 30 days in a row",
            category: .streak,
            xpReward: 150,
            gameCenterID: "geografy.achievement.monthly_champion",
            iconName: "calendar.badge.checkmark",
            isSecret: false
        ),
        AchievementDefinition(
            id: "dedicated_scholar",
            title: "Dedicated Scholar",
            description: "Log in 100 days in a row",
            category: .streak,
            xpReward: 200,
            gameCenterID: "geografy.achievement.dedicated_scholar",
            iconName: "medal.fill",
            isSecret: true
        ),
    ]
}

// MARK: - Knowledge

private extension AchievementCatalog {
    static let knowledge: [AchievementDefinition] = [
        AchievementDefinition(
            id: "flag_collector",
            title: "Flag Collector",
            description: "Complete 5 flag quizzes",
            category: .knowledge,
            xpReward: 50,
            gameCenterID: "geografy.achievement.flag_collector",
            iconName: "flag.fill",
            isSecret: false
        ),
        AchievementDefinition(
            id: "capital_expert",
            title: "Capital Expert",
            description: "Complete 5 capital quizzes",
            category: .knowledge,
            xpReward: 50,
            gameCenterID: "geografy.achievement.capital_expert",
            iconName: "building.columns.fill",
            isSecret: false
        ),
        AchievementDefinition(
            id: "org_scholar",
            title: "Org Scholar",
            description: "Explore all 16 organizations",
            category: .knowledge,
            xpReward: 75,
            gameCenterID: "geografy.achievement.org_scholar",
            iconName: "building.2.fill",
            isSecret: false
        ),
    ]
}
