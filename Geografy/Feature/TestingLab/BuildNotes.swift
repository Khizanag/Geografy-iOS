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
}

// MARK: - This Build
/// The changes to try in this build, newest first. Rewritten with every build handed over for testing, so it lists
/// only what that build adds.
struct BuildNotes {
    let go: BuildNoteRoutes

    var current: [BuildNote] {
        [accountData, quizFlow, speedRunStart, wordSearch, noSound]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var accountData: BuildNote {
        BuildNote(
            commit: "b1cb3cdb",
            title: "Delete Account removes everything",
            howToTest: """
                Sign in with the test account in the Testing Lab, add a favorite and a visited country, then \
                Delete Account: favorites, travel, and progress are all gone for the fresh guest.
                """,
            systemImage: "trash.fill",
            color: DesignSystem.Color.destructive
        ) {
            go.open(.settings)
        }
    }

    var quizFlow: BuildNote {
        BuildNote(
            commit: "671a245b",
            title: "Quizzes play as before",
            howToTest: """
                The quiz's rules moved into a tested model. Play a quiz, an arcade game, and a typed one: \
                streaks, lives, the score, and results should all behave as before.
                """,
            systemImage: "questionmark.circle.fill",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }

    var speedRunStart: BuildNote {
        BuildNote(
            commit: "44b7520a",
            title: "Speed Run starts at once",
            howToTest: """
                Tap Start Speed Run: the run covers the screen with no pause, and closing it returns to Play.
                """,
            systemImage: "bolt.fill",
            color: DesignSystem.Color.pink
        ) {
            go.open(.speedRun)
        }
    }

    var wordSearch: BuildNote {
        BuildNote(
            commit: "f8982bf4",
            title: "Word Search clock fits",
            howToTest: """
                Start a puzzle: the clock at the top left shows the time in full instead of a squeezed circle.
                """,
            systemImage: "textformat.abc",
            color: DesignSystem.Color.teal
        ) {
            go.open(.wordSearch)
        }
    }

    var noSound: BuildNote {
        BuildNote(
            commit: "cfa7cf9b",
            title: "No more silent sound toggle",
            howToTest: """
                Settings no longer has a Sound effects switch, which did nothing; haptics and pronunciation stay.
                """,
            systemImage: "speaker.slash.fill",
            color: DesignSystem.Color.indigo
        ) {
            go.open(.settings)
        }
    }
}
#endif
