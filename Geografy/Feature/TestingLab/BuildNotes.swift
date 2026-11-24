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
            lobbySections,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var lobbySections: BuildNote {
        BuildNote(
            commit: "42052e40",
            title: "Lobby settings in sections",
            howToTest: """
                Host a Local Play game and switch through the five games: the chosen game names the top section, \
                and its settings follow in titled sections, Region first where there is one, as on Pin Drop. Word \
                Search picks its theme from the same tiles as its own setup.
                """,
            systemImage: "list.bullet.rectangle",
            color: DesignSystem.Color.teal
        ) {
            go.open(.multiplayer)
        }
    }
}
#endif
