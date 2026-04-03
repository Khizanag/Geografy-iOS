import Geografy_Core_Navigation
#if os(iOS)
import AppIntents

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
#endif
