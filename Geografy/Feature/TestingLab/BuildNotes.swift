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
            leaveGameButton,
            customQuizCountries,
            flashcardAlignment,
            wordSearchAlignment,
            pinDropGiveUp,
            dailyChallengeQuiz,
            mapPuzzleQuiz,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var leaveGameButton: BuildNote {
        BuildNote(
            commit: "dbc4042c",
            title: "Close button in every game",
            howToTest: """
                Start any game, such as Map Puzzle. Top left is the standard close button instead of the red flag; \
                tapping it still asks before you leave.
                """,
            systemImage: "xmark",
            color: DesignSystem.Color.textSecondary
        ) {
            go.open(.mapPuzzle)
        }
    }

    var mapPuzzleQuiz: BuildNote {
        BuildNote(
            commit: "1bbff145",
            title: "Map Puzzle plays like a quiz",
            howToTest: """
                Start Map Puzzle. The map sits on top and the answers are glass buttons at the bottom, the next \
                question comes a moment after each answer, and Give Up asks before leaving.
                """,
            systemImage: "puzzlepiece.fill",
            color: DesignSystem.Color.purple
        ) {
            go.open(.mapPuzzle)
        }
    }

    var dailyChallengeQuiz: BuildNote {
        BuildNote(
            commit: "23be5638",
            title: "Daily challenges ask like a quiz",
            howToTest: """
                Play today's challenge. Capital Chain and Flag Sequence show the quiz's progress bar, prompt, \
                and answers at the bottom; Mystery Country keeps its guess at the bottom and shows the answer \
                for a moment before finishing.
                """,
            systemImage: "calendar",
            color: DesignSystem.Color.orange
        ) {
            go.open(.dailyChallenge)
        }
    }

    var pinDropGiveUp: BuildNote {
        BuildNote(
            commit: "450bacb6",
            title: "Pin Drop opens full screen",
            howToTest: """
                Start Pin Drop. It covers the screen like a quiz, Give Up asks before leaving, and the round \
                shows in the same counter pill as a quiz.
                """,
            systemImage: "mappin.and.ellipse",
            color: DesignSystem.Color.orange
        ) {
            go.open(.pinDrop)
        }
    }

    var wordSearchAlignment: BuildNote {
        BuildNote(
            commit: "ca2ed1e2",
            title: "Word Search: Give Up and feedback",
            howToTest: """
                Start a puzzle. Give Up is top left and the clock sits beside Pause. Drag across letters that \
                spell no word and it buzzes; drag a word backwards and it still counts. Reveal All asks first.
                """,
            systemImage: "textformat.abc",
            color: DesignSystem.Color.indigo
        ) {
            go.open(.wordSearch)
        }
    }

    var flashcardAlignment: BuildNote {
        BuildNote(
            commit: "beb9d762",
            title: "Flashcards: Give Up and results",
            howToTest: """
                Start a review. Give Up is top left, the rating buttons are glass, a rating or swipe sounds like \
                a quiz answer, and the end is the shared results screen with Study Again.
                """,
            systemImage: "brain.fill",
            color: DesignSystem.Color.purple
        ) {
            go.open(.srsStudy)
        }
    }

    var customQuizCountries: BuildNote {
        BuildNote(
            commit: "8b6e6319",
            title: "Custom quizzes use their countries",
            howToTest: """
                Build a custom quiz with a few countries and play it. The questions are about those countries, \
                at the difficulty you chose, and it opens full screen with Give Up.
                """,
            systemImage: "square.and.pencil",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quizPacks)
        }
    }
}
#endif
