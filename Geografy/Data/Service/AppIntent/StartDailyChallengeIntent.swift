#if os(iOS)
import AppIntents

struct StartDailyChallengeIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Daily Challenge"
    static let description: IntentDescription = "Opens the daily geography challenge."
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppRequests.shared.send(.dailyChallenge)
        return .result()
    }
}
#endif
