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
            multiplayerNameOnce,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var multiplayerNameOnce: BuildNote {
        BuildNote(
            commit: "f2aab70e",
            title: "Multiplayer: Name Asked Once",
            howToTest: """
                Open Multiplayer. With a name already on your profile there's no name field, just a "Playing as" \
                pill under the title. Change the name in Profile, then come back: the pill shows the new name.
                """,
            systemImage: "person.2.fill",
            color: DesignSystem.Color.teal
        ) {
            go.open(.multiplayer)
        }
    }
}
#endif
