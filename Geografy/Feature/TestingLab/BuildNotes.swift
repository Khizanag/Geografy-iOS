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
        [widgets, speedRunLeaderboard]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var widgets: BuildNote {
        BuildNote(
            commit: "3e63da13",
            title: "Widgets still show your progress",
            howToTest: """
                The widgets now find the app's shared data through the build settings. Play a quiz, then check \
                the streak, progress, and Country of the Day widgets still show your numbers.
                """,
            systemImage: "square.grid.2x2.fill",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }

    var speedRunLeaderboard: BuildNote {
        BuildNote(
            commit: "2230c3f2",
            title: "Giving up a Speed Run posts no time",
            howToTest: """
                Start a Speed Run and Give Up: the run ends as before, but no time goes to Game Center. A run \
                that names every country still posts.
                """,
            systemImage: "timer",
            color: DesignSystem.Color.pink
        ) {
            go.open(.speedRun)
        }
    }
}
#endif
