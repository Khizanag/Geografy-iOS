import AppIntents
import Foundation

/// "Siri, start a flag quiz." Opens the app and posts a notification that
/// `ContentView` listens for (existing `.startQuiz` notification pathway)
/// so it can route to the Quiz tab and pick the requested region if any.
public struct StartQuizIntent: AppIntent {
    public static let title: LocalizedStringResource = "Start a Quiz"
    public static let description = IntentDescription(
        "Starts a geography quiz. Optionally filter by region."
    )
    public static let openAppWhenRun: Bool = true

    @Parameter(title: "Region", description: "Filter by continent (optional).")
    public var region: QuizRegion?

    public init() {}

    public init(region: QuizRegion? = nil) {
        self.region = region
    }

    public func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(
            name: Notification.Name("com.khizanag.geografy.startQuiz"),
            object: region?.rawValue
        )
        return .result()
    }
}

/// "Siri, what's my Geografy streak?" — returns a spoken answer without
/// requiring the app to foreground.
public struct ShowStreakIntent: AppIntent {
    public static let title: LocalizedStringResource = "Show my streak"
    public static let description = IntentDescription(
        "Speaks your current daily streak in Geografy."
    )
    public static let openAppWhenRun: Bool = false

    public init() {}

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let streak = UserDefaults.standard.integer(forKey: "current_streak")
        let message: String
        switch streak {
        case 0:         message = "No streak yet — open Geografy to start one."
        case 1:         message = "You're on a one-day streak. Keep it going!"
        default:        message = "You're on a \(streak)-day streak."
        }
        return .result(dialog: IntentDialog(stringLiteral: message))
    }
}

/// "Siri, Geografy country of the day" — deep-links into the daily challenge.
public struct CountryOfTheDayIntent: AppIntent {
    public static let title: LocalizedStringResource = "Country of the Day"
    public static let description = IntentDescription(
        "Opens today's daily challenge in Geografy."
    )
    public static let openAppWhenRun: Bool = true

    public init() {}

    public func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(
            name: Notification.Name("com.khizanag.geografy.startDailyChallenge"),
            object: nil
        )
        return .result()
    }
}

// MARK: - Parameters
public enum QuizRegion: String, AppEnum, CaseIterable, Sendable {
    case africa
    case asia
    case europe
    case northAmerica
    case southAmerica
    case oceania

    public static let typeDisplayRepresentation: TypeDisplayRepresentation = "Region"

    public static let caseDisplayRepresentations: [QuizRegion: DisplayRepresentation] = [
        .africa: "Africa",
        .asia: "Asia",
        .europe: "Europe",
        .northAmerica: "North America",
        .southAmerica: "South America",
        .oceania: "Oceania",
    ]
}

// MARK: - Shortcuts
public struct GeografyShortcuts: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartQuizIntent(),
            phrases: [
                "Start a quiz in \(.applicationName)",
                "Start a \(\.$region) quiz in \(.applicationName)",
            ],
            shortTitle: "Start Quiz",
            systemImageName: "gamecontroller.fill"
        )
        AppShortcut(
            intent: ShowStreakIntent(),
            phrases: [
                "What's my streak in \(.applicationName)",
                "Show my \(.applicationName) streak",
            ],
            shortTitle: "My Streak",
            systemImageName: "flame.fill"
        )
        AppShortcut(
            intent: CountryOfTheDayIntent(),
            phrases: [
                "Open the country of the day in \(.applicationName)",
                "Today's \(.applicationName) challenge",
            ],
            shortTitle: "Daily Challenge",
            systemImageName: "calendar.badge.clock"
        )
    }
}
