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
            tabBarGap,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var tabBarGap: BuildNote {
        BuildNote(
            commit: "2d9f6a9f",
            title: "Buttons clear the tab bar",
            howToTest: """
                Open Speed Run, or any game's setup: Start sits a little above the tab bar instead of touching \
                it. Then tap the Guide button: its Next still sits right on the home indicator, with no extra \
                space below.
                """,
            systemImage: "rectangle.bottomhalf.inset.filled",
            color: DesignSystem.Color.blue
        ) {
            go.open(.speedRun)
        }
    }
}
#endif
