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
            unclippedChips,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var unclippedChips: BuildNote {
        BuildNote(
            commit: "d7341ddb",
            title: "Chips aren't cut when pressed",
            howToTest: """
                In Travel, press and hold each status chip: its glass swells without being cut at the top or \
                bottom. Do the same with the Timeline's filter row.
                """,
            systemImage: "capsule.on.capsule",
            color: DesignSystem.Color.blue
        ) {
            go.open(.travel)
        }
    }
}
#endif
