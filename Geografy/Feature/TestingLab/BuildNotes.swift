#if DEBUG
import Geografy_Core_DesignSystem
import SwiftUI
import TestingLab

/// Ways into the app for this build's notes, so each change can open where it is.
struct BuildNoteRoutes {
    let open: @MainActor (HubItem) -> Void
    let selectTab: @MainActor (AppTab) -> Void
    let showLevelUp: @MainActor () -> Void
    /// For changes only Testing Mode shows.
    let enableTestingMode: @MainActor () -> Void
    let showFirstRun: @MainActor () -> Void
}

// MARK: - This Build
/// The changes to try in this build, newest first. Rewritten with every build handed over for testing, so it lists
/// only what that build adds.
struct BuildNotes {
    let go: BuildNoteRoutes

    var current: [BuildNote] {
        [
            everyGameLocalPlay,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var everyGameLocalPlay: BuildNote {
        BuildNote(
            commit: "de99c5a5",
            title: "Every game in Local Play",
            howToTest: """
                With a second phone, host a Local Play game: the game picker has Quiz, Map Puzzle, Pin Drop, Speed \
                Run, and Word Search. Play Map Puzzle (same countries, the other's score under the map), then Word \
                Search and Speed Run, which end the moment one of you finishes. Each ends on the shared result.
                """,
            systemImage: "person.2.fill",
            color: DesignSystem.Color.teal
        ) {
            go.open(.multiplayer)
        }
    }
}
#endif
