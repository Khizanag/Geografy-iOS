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
            straightWordSearchDrag,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var straightWordSearchDrag: BuildNote {
        BuildNote(
            commit: "d9e1c81d",
            title: "Word Search drags run straight",
            howToTest: """
                Start a Word Search and drag at an odd angle, between a diagonal and a column. The highlight \
                snaps to the nearest straight line, across, down, or diagonal, and never slants between cells. \
                Drag past the edge: it stops at the last cell.
                """,
            systemImage: "line.diagonal",
            color: DesignSystem.Color.blue
        ) {
            go.open(.wordSearch)
        }
    }
}
#endif
