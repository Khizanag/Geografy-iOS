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
            countryFlight,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var countryFlight: BuildNote {
        BuildNote(
            commit: "9b75761d",
            title: "Fly to a found country",
            howToTest: """
                On the Map tab, tap the magnifier and pick a country, such as Chile or Japan. The map should fly \
                there smoothly as the sheet closes: sharp the whole way, no blur, and no jump when it lands. \
                Pinching or dragging mid-flight should take over from where the map is.
                """,
            systemImage: "location.magnifyingglass",
            color: DesignSystem.Color.blue
        ) {
            go.selectTab(.map)
        }
    }
}
#endif
