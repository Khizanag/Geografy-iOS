#if os(iOS)
import AppIntents

enum AppDestination: String, AppEnum {
    case home
    case quiz
    case countries
    case maps
    case more

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Tab"

    static let caseDisplayRepresentations: [AppDestination: DisplayRepresentation] = [
        .home: "Home",
        .quiz: "Quiz",
        .countries: "Countries",
        .maps: "Maps",
        .more: "More",
    ]

    var tabIndex: Int {
        switch self {
        case .home: 0
        case .quiz: 1
        case .countries: 2
        case .maps: 3
        case .more: 4
        }
    }
}
#endif
