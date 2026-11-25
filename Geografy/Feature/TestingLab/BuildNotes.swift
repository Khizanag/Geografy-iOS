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
            profileToolbarAndStats,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var profileToolbarAndStats: BuildNote {
        BuildNote(
            commit: "bde08315",
            title: "Settings gear, glass stats",
            howToTest: """
                Open the Profile tab: Settings is the gear at the top right, and the App section is gone. The \
                streak, level, and explored stats are glass buttons that swell and tick when pressed.
                """,
            systemImage: "gearshape",
            color: DesignSystem.Color.blue
        ) {
            go.selectTab(.profile)
        }
    }
}
#endif
