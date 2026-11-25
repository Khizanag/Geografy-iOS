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
            collectionRows,
            travelPickerToggle,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var collectionRows: BuildNote {
        BuildNote(
            commit: "954d9b9d",
            title: "Collection rows act like rows",
            howToTest: """
                Open Saved, then Collections, then a collection with a country. Tap the country to open it, \
                long-press it for its preview with Open, Copy, Share, and Remove, and swipe it to remove it.
                """,
            systemImage: "folder",
            color: DesignSystem.Color.blue
        ) {
            go.open(.favorites)
        }
    }

    var travelPickerToggle: BuildNote {
        BuildNote(
            commit: "954d9b9d",
            title: "Add and remove in the travel picker",
            howToTest: """
                In Travel, choose Want to Visit and tap Add Country. Tap a country: its plus morphs into a check. \
                Tap it again: it comes off the list and the check turns back into a plus.
                """,
            systemImage: "plus.circle",
            color: DesignSystem.Color.orange
        ) {
            go.open(.travel)
        }
    }
}
#endif
