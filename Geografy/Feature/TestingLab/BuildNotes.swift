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
            speedRunCountrySheet,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var speedRunCountrySheet: BuildNote {
        BuildNote(
            commit: "794cbc72",
            title: "Open a country from results",
            howToTest: """
                Finish or give up a Speed Run, then tap any country under Missed or Named: its page opens in a \
                sheet over the results, and closing it returns to them. Each row now ends in a chevron.
                """,
            systemImage: "doc.text.magnifyingglass",
            color: DesignSystem.Color.pink
        ) {
            go.open(.speedRun)
        }
    }
}
#endif
