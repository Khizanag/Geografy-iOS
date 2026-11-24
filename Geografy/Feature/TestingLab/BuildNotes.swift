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
            oneCardCorner,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var oneCardCorner: BuildNote {
        BuildNote(
            commit: "f2e8fcdc",
            title: "One card corner, glass banners",
            howToTest: """
                Open Profile: the Save your progress banner is now tinted glass, and it, the cards, and the \
                statistics tiles all share one corner. Tap the banner: the glass answers the press. Also check \
                an unlocked achievement's Unlocked panel, and a custom quiz's continent list, now one card.
                """,
            systemImage: "rectangle.roundedtop",
            color: DesignSystem.Color.blue
        ) {
            go.open(.profile)
        }
    }
}
#endif
