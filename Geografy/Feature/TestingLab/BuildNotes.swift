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
            rollingChartNumbers,
            hapticsFromViews,
            resultsInPlace,
            systemGlassButtons,
            questionAtTop,
            rareAccent,
            calmCopy,
            studyFirst,
            mapPuzzleRounds,
            fullWidthLastTile,
            oneGamesSection,
            gamesOpenOnSetup,
            setupFactButtons,
            answerWaiting,
            glassAnswers,
            guideNavigation,
            gameGuides,
            mapPuzzleWorld,
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
    var rollingChartNumbers: BuildNote {
        BuildNote(
            commit: "8ef2b8cb",
            title: "Chart numbers roll",
            howToTest: """
                Open a country, then an indicator such as Electricity Access. Hold and drag along the line: the \
                big value and its year roll to each point instead of jumping. Switch 10Y, 20Y, 30Y: the summary \
                values roll too.
                """,
            systemImage: "chart.line.uptrend.xyaxis",
            color: DesignSystem.Color.blue
        ) {
            go.open(.countries)
        }
    }

    var hapticsFromViews: BuildNote {
        BuildNote(
            commit: "ca0a05bc",
            title: "Haptics only on a change",
            howToTest: """
                Tapping a tile, a row, or Start no longer buzzes. A right answer taps success and a wrong one taps \
                error, in every game. Toggling a favorite, picking a region or an option, swapping a pair, and \
                saving a journal entry each tap once. Turn Haptics off in Settings: none of them play.
                """,
            systemImage: "iphone.radiowaves.left.and.right",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }

    var resultsInPlace: BuildNote {
        BuildNote(
            commit: "eae51c7a",
            title: "Quiz results in place",
            howToTest: """
                Finish a 5-question quiz: the results replace the questions on the same screen, with no back \
                button. Play Again starts a new round right there; Done closes the quiz.
                """,
            systemImage: "checkmark.seal",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }

    var systemGlassButtons: BuildNote {
        BuildNote(
            commit: "cea0df77",
            title: "System glass buttons",
            howToTest: """
                On the Map, tap a country: More info is filled green glass. In Travel, the status chips are glass, \
                with the active one filled in its colour. In a typing quiz, Hint is a glass capsule; in Spelling \
                Bee, so is Skip. Pressing a card no longer buzzes; the screen it opens does.
                """,
            systemImage: "capsule",
            color: DesignSystem.Color.blue
        ) {
            go.open(.travel)
        }
    }

    var questionAtTop: BuildNote {
        BuildNote(
            commit: "b08c7626",
            title: "Questions start at the top",
            howToTest: """
                Play a few Neighbors and Flag Quiz questions: each question starts right under the progress bar, \
                at the same place every time, and the answers stay at the bottom. Try Typing mode too.
                """,
            systemImage: "arrow.up.to.line",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }

    var rareAccent: BuildNote {
        BuildNote(
            commit: "eca03bc5 2920fd96",
            title: "Accent only where it means something",
            howToTest: """
                Start buttons are filled green glass; other buttons are plain glass. Open France: section icons and \
                small labels are white or grey, not green. Green stays on progress bars, selected tiles, charts, \
                and toggles. Open an achievement: Pin to Showcase is a glass button.
                """,
            systemImage: "paintpalette",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }

    var calmCopy: BuildNote {
        BuildNote(
            commit: "55c9bd53",
            title: "Calm copy and app-worded search",
            howToTest: """
                Finish a quiz, a Map Puzzle, and a Local Play match: titles read without exclamation marks, and a \
                lost match says "Your Opponent Won". Search Countries for "zzz": the empty state reads No Results \
                for “zzz” in the app's own words.
                """,
            systemImage: "text.bubble",
            color: DesignSystem.Color.blue
        ) {
            go.open(.search)
        }
    }

    var studyFirst: BuildNote {
        BuildNote(
            commit: "e25e26cb",
            title: "Study before Games",
            howToTest: "Open Play: Study, with Learning Path and Flashcards, sits above Games.",
            systemImage: "graduationcap",
            color: DesignSystem.Color.blue
        ) {
            go.open(.learningPath)
        }
    }

    var mapPuzzleRounds: BuildNote {
        BuildNote(
            commit: "185d8f84",
            title: "Map Puzzle rounds",
            howToTest: """
                Open Map Puzzle. Under Game, pick Rounds: 5, 10, 20, 30, or 50, as Quiz offers. Choose South \
                America and 20: the note says a round asks 12, one per country. Start and count the rounds.
                """,
            systemImage: "list.number",
            color: DesignSystem.Color.purple
        ) {
            go.open(.mapPuzzle)
        }
    }

    var fullWidthLastTile: BuildNote {
        BuildNote(
            commit: "bd16aab0",
            title: "Odd last tile is full width",
            howToTest: """
                Open Play and scroll to the end of Games: Multiplayer, alone on its row, spans the full width. \
                Check Explore and Profile too: any section with an odd number of tiles ends the same way.
                """,
            systemImage: "rectangle.split.2x1",
            color: DesignSystem.Color.blue
        ) {
            go.open(.multiplayer)
        }
    }

    var oneGamesSection: BuildNote {
        BuildNote(
            commit: "d45f736f",
            title: "One Games section",
            howToTest: """
                Open Play. Quick Play is gone: every game sits under Games, and Neighbors, True or False, and \
                Mystery Country are only in Quiz, as quiz types.
                """,
            systemImage: "square.grid.2x2",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }

    var gamesOpenOnSetup: BuildNote {
        BuildNote(
            commit: "8de6b7a1",
            title: "Games open on their setup",
            howToTest: """
                On the Map, open a continent and tap Play Map Puzzle: the puzzle setup opens with that continent \
                chosen, instead of the puzzle starting at once.
                """,
            systemImage: "list.bullet.rectangle",
            color: DesignSystem.Color.blue
        ) {
            go.open(.mapPuzzle)
        }
    }

    var setupFactButtons: BuildNote {
        BuildNote(
            commit: "624463cd",
            title: "Header facts are buttons",
            howToTest: """
                Open Quiz. Tap World under the title: the page scrolls to Region. Tap 10 questions: it scrolls to \
                Game. Try the same on Map Puzzle, Pin Drop, and Speed Run.
                """,
            systemImage: "chevron.down.circle",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }

    var answerWaiting: BuildNote {
        BuildNote(
            commit: "0a50f2d4",
            title: "Wait on an answer",
            howToTest: """
                In Quiz setup, set Next Question to On Tap and start a quiz. After each answer the quiz waits: tap \
                the country button to read its page, then Next. With If Right, only a wrong answer waits; Auto \
                moves on as before.
                """,
            systemImage: "hand.raised",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }

    var glassAnswers: BuildNote {
        BuildNote(
            commit: "462ab319",
            title: "Answers are glass capsules",
            howToTest: """
                Start a Neighbors quiz. Each answer is one glass capsule with no inner outline. Tap one: it turns \
                green if right or red if wrong, and the right answer turns green too.
                """,
            systemImage: "capsule",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }

    var guideNavigation: BuildNote {
        BuildNote(
            commit: "eb84d71f",
            title: "Guide: close button and Next",
            howToTest: """
                Open Quiz and tap the ? button. The game's name is the title with a close button beside it. Tap \
                Next through the pages: each one slides in, including the last, where Next becomes Got It.
                """,
            systemImage: "arrow.right.circle",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }

    var gameGuides: BuildNote {
        BuildNote(
            commit: "bfcd4f5c",
            title: "A guide for every game",
            howToTest: """
                Open each game: Quiz, Map Puzzle, Pin Drop, Speed Run, Daily Challenge, Local Play, Word Search, \
                and Flashcards. The first time, its guide opens by itself; after that, the ? button opens it.
                """,
            systemImage: "questionmark.circle",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }

    var mapPuzzleWorld: BuildNote {
        BuildNote(
            commit: "25dd2708",
            title: "Map Puzzle on the whole world",
            howToTest: """
                Open Map Puzzle. Whole World sits on top of the regions, as in Pin Drop; play it and check that \
                small countries, such as Sri Lanka, get a ring so you can find them.
                """,
            systemImage: "globe.americas.fill",
            color: DesignSystem.Color.purple
        ) {
            go.open(.mapPuzzle)
        }
    }

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
