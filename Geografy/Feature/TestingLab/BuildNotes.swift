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
}

// MARK: - This Build
/// The changes to try in this build, newest first. Rewritten with every build handed over for testing, so it lists
/// only what that build adds.
struct BuildNotes {
    let go: BuildNoteRoutes

    var current: [BuildNote] {
        [labShortcuts, sharedLab]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var labShortcuts: BuildNote {
        BuildNote(
            commit: "01d3e435",
            title: "Shortcuts open full screens",
            howToTest: """
                Tap a change here: the lab closes, then its screen opens with all its content, not blank. \
                Try it twice in a row.
                """,
            systemImage: "arrow.up.forward.app.fill",
            color: DesignSystem.Color.blue
        ) {
            go.open(.settings)
        }
    }

    var sharedLab: BuildNote {
        BuildNote(
            commit: "475e5503",
            title: "Testing Lab from the shared package",
            howToTest: """
                Shake to open it, and open it from Settings ▸ Developer too. Every section works as before; \
                Erase Everything and Quit now also clears saved files, so the next launch is a first launch.
                """,
            systemImage: "shippingbox.fill",
            color: DesignSystem.Color.orange
        ) {
            go.open(.settings)
        }
    }
}
#endif
