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

    var tabIndex: Int {
        switch self {
        case .map: AppTab.map.rawValue
        case .explore: AppTab.explore.rawValue
        case .play: AppTab.play.rawValue
        case .profile: AppTab.profile.rawValue
        }
    }
}
#endif
