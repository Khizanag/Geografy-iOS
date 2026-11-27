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
            quizGiveUpResults,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var quizGiveUpResults: BuildNote {
        BuildNote(
            commit: "4a644595",
            title: "Quiz: Give Up Shows Results",
            howToTest: """
                Start a quiz, answer a question or two, then tap the close button and Give Up. You land on the \
                results: the questions you didn't reach count as missed, and XP comes only from right answers. \
                Give Up before answering anything still just closes.
                """,
            systemImage: "flag.checkered",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }
}
#endif
