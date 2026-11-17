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
        [gameColors, resultScreens, speedRunXP, settingsRows, profileFixes]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var gameColors: BuildNote {
        BuildNote(
            commit: "2270c9d3",
            title: "Colors that don't mean right or wrong",
            howToTest: """
                Hub tiles and games use blue, pink, teal, and purple; green shows only success and red only \
                errors or deleting. XP and levels are gold everywhere.
                """,
            systemImage: "paintpalette.fill",
            color: DesignSystem.Color.pink
        ) {
            go.selectTab(.play)
        }
    }

    var resultScreens: BuildNote {
        BuildNote(
            commit: "39779839",
            title: "One results screen for every game",
            howToTest: """
                Finish a quiz, Speed Run, Daily Challenge, Map Puzzle, Pin Drop, and a two-player game: each \
                shows the same title, gold XP badge, stat tiles, and Done beside the main action.
                """,
            systemImage: "flag.checkered",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }

    var speedRunXP: BuildNote {
        BuildNote(
            commit: "0d3c6926",
            title: "No XP for giving up a Speed Run",
            howToTest: """
                Start a Speed Run and give up at once: +0 XP and no streak day. Name some countries first and \
                the XP matches how many.
                """,
            systemImage: "stopwatch.fill",
            color: DesignSystem.Color.pink
        ) {
            go.open(.speedRun)
        }
    }

    var settingsRows: BuildNote {
        BuildNote(
            commit: "78dff61d",
            title: "Sign Out asks first",
            howToTest: """
                Sign Out and Delete Account are red in Settings and Profile, and both ask before acting. \
                Territorial Disputes and Storage share one red Reset button.
                """,
            systemImage: "rectangle.portrait.and.arrow.right",
            color: DesignSystem.Color.destructive
        ) {
            go.open(.settings)
        }
    }

    var profileFixes: BuildNote {
        BuildNote(
            commit: "78dff61d",
            title: "Profile counts explored countries",
            howToTest: """
                Profile's Explored stat matches the Profile tab, achievement names no longer cut off, and \
                Recent Quizzes is one card.
                """,
            systemImage: "person.crop.circle.fill",
            color: DesignSystem.Color.indigo
        ) {
            go.selectTab(.profile)
        }
    }
}
#endif
