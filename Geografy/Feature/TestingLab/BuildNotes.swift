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
            speedRunFieldBar,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var speedRunFieldBar: BuildNote {
        BuildNote(
            commit: "bebb039f",
            title: "Speed Run field floats over the list",
            howToTest: """
                Start a Speed Run and name enough countries to fill the list: the rows scroll under the field, \
                softly blurred at the edge as under any bar, with no solid band behind the field.
                """,
            systemImage: "keyboard",
            color: DesignSystem.Color.pink
        ) {
            go.open(.speedRun)
        }
    }
}
#endif
