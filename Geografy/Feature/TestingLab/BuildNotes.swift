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
            smallCountryMarkers,
            lowerBottomButtons,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var smallCountryMarkers: BuildNote {
        BuildNote(
            commit: "9253a075",
            title: "Small countries marked",
            howToTest: """
                Start a Speed Run in Europe with Show Map on: Monaco, the Vatican, San Marino, Malta, and the \
                other tiny countries each have a white ring. Name Monaco: its ring turns into a green dot.
                """,
            systemImage: "smallcircle.filled.circle",
            color: DesignSystem.Color.pink
        ) {
            go.open(.speedRun)
        }
    }

    var lowerBottomButtons: BuildNote {
        BuildNote(
            commit: "2f261037",
            title: "Bottom buttons lower",
            howToTest: """
                Finish a Speed Run or a quiz: Done and Play Again sit right above the home indicator, with no \
                extra gap. Start buttons on the setup pages sit just above the tab bar.
                """,
            systemImage: "rectangle.bottomthird.inset.filled",
            color: DesignSystem.Color.blue
        ) {
            go.open(.speedRun)
        }
    }
}
#endif
