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
            recentLongPress,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var recentLongPress: BuildNote {
        BuildNote(
            commit: "480475bf",
            title: "Long-press a recent",
            howToTest: """
                In Distance Calculator, Compare, and Currency Converter, long-press an item under Recent: a \
                preview shows both flags and, for a route, its distance; the menu offers Open, Copy, Share, and \
                Remove in red. Swiping left still removes it too.
                """,
            systemImage: "hand.point.up.left",
            color: DesignSystem.Color.blue
        ) {
            go.open(.distanceCalculator)
        }
    }
}
#endif
