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
            countryLongPress,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var countryLongPress: BuildNote {
        BuildNote(
            commit: "fe4b2fdc",
            title: "Long-press a country",
            howToTest: """
                Finish or give up a Speed Run, then long-press a country under Missed or Named: a preview shows \
                its flag, continent, capital, population, and area, with Open, Copy, and Share below. Open shows \
                its page in a sheet, as a tap does.
                """,
            systemImage: "hand.point.up.left",
            color: DesignSystem.Color.pink
        ) {
            go.open(.speedRun)
        }
    }
}
#endif
