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
            centeredMapLoader,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var centeredMapLoader: BuildNote {
        BuildNote(
            commit: "4d69b42a",
            title: "Map loader where the map appears",
            howToTest: """
                Relaunch the app, or switch the map's Projection: the loading globe sits at the centre the world \
                fills, with Loading map and the data credit below it, and the map fades in around it.
                """,
            systemImage: "globe.americas",
            color: DesignSystem.Color.blue
        ) {
            go.selectTab(.map)
        }
    }
}
#endif
