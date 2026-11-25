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
            snugSheets,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var snugSheets: BuildNote {
        BuildNote(
            commit: "c3e38ec8",
            title: "Sheets end where they end",
            howToTest: """
                Open any achievement: below Pin to Showcase there's only the padding the sides have, and the \
                sheet doesn't jump. Check a country's Travel Status sheet and a fun fact too.
                """,
            systemImage: "rectangle.bottomhalf.filled",
            color: DesignSystem.Color.blue
        ) {
            go.open(.achievements)
        }
    }
}
#endif
