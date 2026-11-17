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
        [shareResults, links, firstRun, mapZoom, lessonQuizzes, knowledgeMap, continentPuzzle, gameReviews]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var shareResults: BuildNote {
        BuildNote(
            commit: "95ed0e04",
            title: "Share any result",
            howToTest: """
                Finish a quiz, a Speed Run, a Pin Drop game, or the Daily Challenge, then tap the share button \
                beside Done: the share sheet shows a card with your score.
                """,
            systemImage: "square.and.arrow.up",
            color: DesignSystem.Color.indigo
        ) {
            go.open(.quiz)
        }
    }

    var links: BuildNote {
        BuildNote(
            commit: "ff918aff",
            title: "Links and widget taps open the right place",
            howToTest: """
                Tap the Country of the Day widget: the app opens on that country. In Safari, \
                geografy://country/jp opens Japan and geografy://daily opens today's challenge.
                """,
            systemImage: "link",
            color: DesignSystem.Color.blue
        ) {
            go.selectTab(.explore)
        }
    }

    var firstRun: BuildNote {
        BuildNote(
            commit: "cdb144ef",
            title: "First run for new players",
            howToTest: """
                Opens the welcome now. Pick a home country and finish: today's Daily Challenge opens, home is \
                marked visited, and the Map tab flies to it.
                """,
            systemImage: "sparkles",
            color: DesignSystem.Color.orange
        ) {
            go.showFirstRun()
        }
    }

    var mapZoom: BuildNote {
        BuildNote(
            commit: "3de648c0",
            title: "The map keeps its zoom",
            howToTest: "Zoom into the world map, switch to another tab and back: the map stays where you left it.",
            systemImage: "map.fill",
            color: DesignSystem.Color.teal
        ) {
            go.selectTab(.map)
        }
    }

    var lessonQuizzes: BuildNote {
        BuildNote(
            commit: "b2095c93",
            title: "Learning Path quizzes are real",
            howToTest: """
                Open a module's quiz lesson and start it: it completes only at 80% or more, and shows your last \
                score with Try Again below that.
                """,
            systemImage: "graduationcap.fill",
            color: DesignSystem.Color.purple
        ) {
            go.open(.learningPath)
        }
    }

    var knowledgeMap: BuildNote {
        BuildNote(
            commit: "c5f1d242",
            title: "How well you know each continent",
            howToTest: "Spaced Repetition shows each continent's countries colored by how well you know them.",
            systemImage: "square.grid.2x2.fill",
            color: DesignSystem.Color.pink
        ) {
            go.open(.srsStudy)
        }
    }

    var continentPuzzle: BuildNote {
        BuildNote(
            commit: "a8af94d0",
            title: "Map Puzzle from a continent",
            howToTest: "On a continent's map or overview, the menu has Play Map Puzzle for that continent.",
            systemImage: "puzzlepiece.fill",
            color: DesignSystem.Color.orange
        ) {
            go.selectTab(.map)
        }
    }

    var gameReviews: BuildNote {
        BuildNote(
            commit: "b843de8b",
            title: "Games count toward flashcard reviews",
            howToTest: """
                Play a flag or capital quiz and miss some: the results offer Review Missed, and those cards are \
                due in Spaced Repetition.
                """,
            systemImage: "rectangle.on.rectangle.angled",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }
}
#endif
