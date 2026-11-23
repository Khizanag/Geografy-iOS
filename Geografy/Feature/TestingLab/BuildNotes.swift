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
            pressHaptics,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var pressHaptics: BuildNote {
        BuildNote(
            commit: "01644de9",
            title: "Presses tap again",
            howToTest: """
                Tap hub tiles, list rows, cards, and Start, Next, or Done: each press taps lightly, cards at half \
                strength. A right or wrong answer, a favorite, and a Travel filter still play their own haptic. \
                Turn Haptics off in Settings: none play.
                """,
            systemImage: "hand.tap",
            color: DesignSystem.Color.blue
        ) {
            go.selectTab(.play)
        }
    }
}
#endif
