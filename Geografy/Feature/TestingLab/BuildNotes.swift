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
        [xpForEveryGame, learningStreak, reminders, flashcardCap]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var xpForEveryGame: BuildNote {
        BuildNote(
            commit: "44f3caea",
            title: "XP for every game",
            howToTest: """
                Daily Challenge, Pin Drop, Map Puzzle, Flashcards, lessons, and Word Search now earn XP: watch \
                Total XP below rise after each. Only the first 25 visited countries pay travel XP.
                """,
            systemImage: "star.fill",
            color: DesignSystem.Color.warning
        ) {
            go.open(.mapPuzzle)
        }
    }

    var learningStreak: BuildNote {
        BuildNote(
            commit: "b51a7460",
            title: "Streak counts learning",
            howToTest: """
                Set Streak to No streak below, then reopen the app: it stays at 0. Finish any quiz, game, \
                lesson, or review: Profile shows 1.
                """,
            systemImage: "flame.fill",
            color: DesignSystem.Color.orange
        ) {
            go.selectTab(.profile)
        }
    }

    var reminders: BuildNote {
        BuildNote(
            commit: "39ef4e6b",
            title: "Smarter reminders",
            howToTest: """
                With reminders on in Settings, none come on a day you've already played. Tapping the 9:00 one \
                opens today's challenge; the 19:00 one opens Play.
                """,
            systemImage: "bell.badge.fill",
            color: DesignSystem.Color.indigo
        ) {
            go.open(.settings)
        }
    }

    var flashcardCap: BuildNote {
        BuildNote(
            commit: "41bc8d54",
            title: "Ten new flashcards a day",
            howToTest: """
                Review shows at most 10 new cards a day, biggest countries first, plus any reviewed cards that \
                are due.
                """,
            systemImage: "rectangle.on.rectangle.angled",
            color: DesignSystem.Color.purple
        ) {
            go.open(.srsStudy)
        }
    }
}
#endif
