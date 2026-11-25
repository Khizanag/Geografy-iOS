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
            mapMenuNames,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var mapMenuNames: BuildNote {
        BuildNote(
            commit: "bc4924e0",
            title: "Shorter Map menu",
            howToTest: """
                On the Map tab, open the More menu: it reads Projection and Colors, without repeating Map.
                """,
            systemImage: "ellipsis.circle",
            color: DesignSystem.Color.blue
        ) {
            go.selectTab(.map)
        }
    }
}
#endif
