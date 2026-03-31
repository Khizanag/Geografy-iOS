#if os(iOS)
import AppIntents
import Foundation

// MARK: - Tab Destination
enum AppDestination: String, AppEnum {
    case home
    case quiz
    case countries
    case maps
    case more

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Tab"

    static let caseDisplayRepresentations: [AppDestination: DisplayRepresentation] = [
        .home: "Home",
        .quiz: "Quiz",
        .countries: "Countries",
        .maps: "Maps",
        .more: "More",
    ]

    var tabIndex: Int {
        switch self {
        case .home: 0
        case .quiz: 1
        case .countries: 2
        case .maps: 3
        case .more: 4
        }
    }
}

// MARK: - Open Geografy Intent
struct OpenGeografyIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Geografy"
    static let description: IntentDescription = "Opens Geografy to a specific tab."
    static let openAppWhenRun = true

    @Parameter(title: "Destination")
    var destination: AppDestination

    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(
            name: .switchTab,
            object: destination.tabIndex
        )
        return .result()
    }
}

// MARK: - Start Quiz Intent
struct StartQuizIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Quiz"
    static let description: IntentDescription = "Starts a quick geography quiz."
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .startQuiz, object: nil)
        return .result()
    }
}

// MARK: - Start Daily Challenge Intent
struct StartDailyChallengeIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Daily Challenge"
    static let description: IntentDescription = "Opens the daily geography challenge."
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .startDailyChallenge, object: nil)
        return .result()
    }
}

// MARK: - App Shortcuts
struct GeografyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartDailyChallengeIntent(),
            phrases: [
                "Start daily challenge in \(.applicationName)",
            ],
            shortTitle: "Daily Challenge",
            systemImageName: "calendar.badge.clock"
        )

        AppShortcut(
            intent: StartQuizIntent(),
            phrases: [
                "Start quiz in \(.applicationName)",
            ],
            shortTitle: "Start Quiz",
            systemImageName: "gamecontroller.fill"
        )
    }
}
#endif
