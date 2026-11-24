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
            speedRunMap,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var speedRunMap: BuildNote {
        BuildNote(
            commit: "7b79313f",
            title: "Speed Run map",
            howToTest: """
                In Speed Run setup, turn on Show Map under Game and start a run in Europe. A map of Europe sits \
                above the list, and each country turns green as you name it, so the gaps show what's left. Try \
                Whole World too.
                """,
            systemImage: "map",
            color: DesignSystem.Color.pink
        ) {
            go.open(.speedRun)
        }
    }
}
#endif
