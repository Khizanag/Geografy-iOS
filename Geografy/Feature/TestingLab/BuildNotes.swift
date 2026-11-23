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
            bottomBar,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var bottomBar: BuildNote {
        BuildNote(
            commit: "d7884504",
            title: "Bottom buttons sit lower",
            howToTest: """
                Open a game's guide with ? and check Next: it sits just above the home indicator, with no extra \
                gap. Check Start on Quiz, Map Puzzle, and Pin Drop, a quiz's results, and Local Play: the same \
                small gap everywhere.
                """,
            systemImage: "rectangle.bottomthird.inset.filled",
            color: DesignSystem.Color.blue
        ) {
            go.open(.dailyChallenge)
        }
    }
}
#endif
