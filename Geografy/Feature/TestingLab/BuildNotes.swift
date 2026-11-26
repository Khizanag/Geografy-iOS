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
            glassFactChips,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var glassFactChips: BuildNote {
        BuildNote(
            commit: "fb4a2e17",
            title: "Glass Setting Chips",
            howToTest: """
                Open any game's setup, such as a quiz or Flashcards. The chips under the title, like region, lives, \
                and time, are now glass like the filter chips. Tap one: it presses like glass and scrolls to that \
                setting.
                """,
            systemImage: "capsule.fill",
            color: DesignSystem.Color.blue
        ) {
            go.open(.srsStudy)
        }
    }
}
#endif
