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
            swipeRecents,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var swipeRecents: BuildNote {
        BuildNote(
            commit: "35e54bcf",
            title: "Swipe a recent away",
            howToTest: """
                In Distance Calculator, Compare, and Currency Converter, open two routes or pairs, then swipe one \
                under Recent to the left: a red Remove appears, and tapping it removes only that one. Long-press a \
                recent for the same Remove. The page still scrolls when you drag up and down over Recent.
                """,
            systemImage: "trash",
            color: DesignSystem.Color.blue
        ) {
            go.open(.distanceCalculator)
        }
    }
}
#endif
