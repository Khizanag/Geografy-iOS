import Foundation
import Observation

/// Somewhere to go that comes from outside the app's screens: a Shortcut, Siri, or a Mac menu command.
enum AppRequest: Equatable {
    case tab(AppTab)
    case quiz
    case dailyChallenge
    case settings
    case search
    case randomCountry
    case country(code: String)
    case profile
    case leaderboards
    /// The first run is done: fly the map to home, if one was chosen, and open today's challenge.
    case firstRunFinished(homeCountryCode: String?)

    /// A request that has to wait for the country list, so one sent at launch isn't dropped.
    var needsCountries: Bool {
        switch self {
        case .randomCountry, .country: true
        default: false
        }
    }
}

// MARK: - Links
extension AppRequest {
    /// The place a `geografy://` link opens, from a widget, a shared result, or anywhere else.
    init?(url: URL) {
        guard url.scheme == WidgetContract.Link.scheme else { return nil }
        switch url.host {
        case WidgetContract.Link.countryHost:
            guard let code = url.pathComponents.dropFirst().first, !code.isEmpty else { return nil }
            self = .country(code: code.uppercased())
        case WidgetContract.Link.dailyHost: self = .dailyChallenge
        case "home", "countries": self = .tab(.explore)
        case "map", "maps": self = .tab(.map)
        case "quiz", "play": self = .tab(.play)
        case "more": self = .tab(.profile)
        case "streak", "profile": self = .profile
        case "progress": self = .leaderboards
        default: return nil
        }
    }
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
