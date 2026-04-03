#if os(iOS)
import AppIntents

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
