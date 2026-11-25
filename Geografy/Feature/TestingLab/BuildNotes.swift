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
            steadySheets,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var steadySheets: BuildNote {
        BuildNote(
            commit: "a7a07786",
            title: "Sheets open at their height",
            howToTest: """
                Open any achievement: its sheet rises straight to its height, with no shrink after it lands. \
                Check the other sheets sized to their content too: a country fact, a fun fact, a timeline \
                event, and the travel status picker.
                """,
            systemImage: "rectangle.bottomhalf.filled",
            color: DesignSystem.Color.blue
        ) {
            go.open(.achievements)
        }
    }
}
#endif
