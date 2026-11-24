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
            multiplayerName,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var multiplayerName: BuildNote {
        BuildNote(
            commit: "0c3378ab",
            title: "Multiplayer, one name",
            howToTest: """
                Open Play, then Multiplayer: the tile says Play with a friend nearby, and the screen, its guide, \
                and the end of a match are titled Multiplayer, with Play Nearby as the way in. Local Play no \
                longer appears anywhere.
                """,
            systemImage: "person.2.fill",
            color: DesignSystem.Color.teal
        ) {
            go.open(.multiplayer)
        }
    }
}
#endif
