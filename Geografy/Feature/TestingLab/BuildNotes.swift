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
            resultStatsScroll,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var resultStatsScroll: BuildNote {
        BuildNote(
            commit: "698c16de",
            title: "Named and Missed scroll to their lists",
            howToTest: """
                Finish or give up a Speed Run: Named and Missed are glass buttons with a down chevron. Tap one: \
                the results scroll to that list. A count with no list, such as 0 named, stays a plain tile.
                """,
            systemImage: "chevron.down.circle",
            color: DesignSystem.Color.pink
        ) {
            go.open(.speedRun)
        }
    }
}
#endif
