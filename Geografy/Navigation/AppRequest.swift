import Observation

/// Somewhere to go that comes from outside the app's screens: a Shortcut, Siri, or a Mac menu command.
enum AppRequest: Equatable {
    case tab(AppTab)
    case quiz
    case dailyChallenge
    case settings
    case search
    case randomCountry
}

/// Holds a request until the root view handles it, so one made while the app is still launching, before any view
/// is listening, isn't lost.
@MainActor
@Observable
final class AppRequests {
    static let shared = AppRequests()

    private(set) var pending: AppRequest?

    func send(_ request: AppRequest) {
        pending = request
    }

    /// The waiting request, which is then cleared so it's handled once.
    func take() -> AppRequest? {
        defer { pending = nil }
        return pending
    }
}
