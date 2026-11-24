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
            glassFormFields,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var glassFormFields: BuildNote {
        BuildNote(
            commit: "79010846",
            title: "Glass capsule text fields",
            howToTest: """
                Open Local Play: Your Name is a glass capsule, the height of the buttons below. Then check the \
                same field in Edit Profile, a custom quiz's name, a journal trip's title and notes, and a bucket \
                list note: one line is a capsule, notes are glass with the card corner.
                """,
            systemImage: "character.cursor.ibeam",
            color: DesignSystem.Color.blue
        ) {
            go.open(.multiplayer)
        }
    }
}
#endif
