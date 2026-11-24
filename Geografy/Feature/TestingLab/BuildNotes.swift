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
            speedRunResults,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var speedRunResults: BuildNote {
        BuildNote(
            commit: "ed0cef19",
            title: "Speed Run results list both",
            howToTest: """
                Name a few countries in a Speed Run and give up: the results list Missed Countries, then Named \
                Countries. With Show Map on, the finished map sits above them, named countries green and tiny \
                missed ones ringed.
                """,
            systemImage: "checklist",
            color: DesignSystem.Color.pink
        ) {
            go.open(.speedRun)
        }
    }
}
#endif
