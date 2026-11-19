#if !os(tvOS)
import SwiftUI

/// What a Local Play match plays: a quiz of any type, or Pin Drop on the map.
public enum LocalGame: String, CaseIterable, Codable, Identifiable, Sendable {
    case quiz
    case pinDrop

    public var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .quiz: "Quiz"
        case .pinDrop: "Pin Drop"
        }
    }

    var systemImage: String {
        switch self {
        case .quiz: "questionmark.bubble.fill"
        case .pinDrop: "mappin.and.ellipse"
        }
    }
}
#endif
