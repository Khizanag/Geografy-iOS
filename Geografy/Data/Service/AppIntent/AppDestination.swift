#if os(iOS)
import AppIntents

enum AppDestination: String, AppEnum {
    case map
    case explore
    case play
    case profile

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Tab"

    static let caseDisplayRepresentations: [AppDestination: DisplayRepresentation] = [
        .map: "Map",
        .explore: "Explore",
        .play: "Play",
        .profile: "Profile",
    ]

    var tab: AppTab {
        switch self {
        case .map: .map
        case .explore: .explore
        case .play: .play
        case .profile: .profile
        }
    }
}
#endif
