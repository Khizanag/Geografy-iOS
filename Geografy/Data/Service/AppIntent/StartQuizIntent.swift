import Geografy_Core_Navigation
#if os(iOS)
import AppIntents

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
#endif
