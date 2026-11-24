#if !os(tvOS)
import SwiftUI

/// What a multiplayer match plays. Every game the app has is here, so two phones can play any of them.
public enum LocalGame: String, CaseIterable, Codable, Identifiable, Sendable {
    case quiz
    case mapPuzzle
    case pinDrop
    case speedRun
    case wordSearch

    public var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .quiz: "Quiz"
        case .mapPuzzle: "Map Puzzle"
        case .pinDrop: "Pin Drop"
        case .speedRun: "Speed Run"
        case .wordSearch: "Word Search"
        }
    }

    var systemImage: String {
        switch self {
        case .quiz: "questionmark.bubble.fill"
        case .mapPuzzle: "puzzlepiece.fill"
        case .pinDrop: "mappin.and.ellipse"
        case .speedRun: "timer"
        case .wordSearch: "character.magnify"
        }
    }

    /// A race ends the moment one player finishes, such as naming every country or finding every word; the other
    /// games end once both players have played every round.
    var isRace: Bool {
        switch self {
        case .speedRun, .wordSearch: true
        case .quiz, .mapPuzzle, .pinDrop: false
        }
    }
}
#endif
