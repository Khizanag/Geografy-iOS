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
            namedTinyCountries,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var namedTinyCountries: BuildNote {
        BuildNote(
            commit: "b5cbf3c6",
            title: "Named tiny countries lose their ring",
            howToTest: """
                In a Speed Run of Europe with Show Map on, name Monaco: its ring disappears and only the country \
                itself fills green. The rings left are the countries still to find.
                """,
            systemImage: "circle.dashed",
            color: DesignSystem.Color.pink
        ) {
            go.open(.speedRun)
        }
    }
}
#endif
