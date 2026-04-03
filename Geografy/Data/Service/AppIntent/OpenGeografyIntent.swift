import Geografy_Core_Navigation
#if os(iOS)
import AppIntents

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
#endif
