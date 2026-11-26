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
            answersStayInPlace,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var answersStayInPlace: BuildNote {
        BuildNote(
            commit: "69ae0ecc",
            title: "Answers stay put between questions",
            howToTest: """
                Play Map Puzzle, then a Quiz, and answer a few questions: the question or map slides to the next, \
                and the four answers stay where they are, fading and rising in with the new names. Nothing slides \
                sideways and back. Check the daily Capital Chain and Flag Sequence too.
                """,
            systemImage: "list.bullet.rectangle",
            color: DesignSystem.Color.blue
        ) {
            go.open(.mapPuzzle)
        }
    }
}
#endif
