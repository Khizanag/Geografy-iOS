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
            flashcardsTwoAnswers,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var flashcardsTwoAnswers: BuildNote {
        BuildNote(
            commit: "36d6f339",
            title: "Flashcards: Wrong or Got It",
            howToTest: """
                Open Flashcards and Study. Turn a card over: under it are just Wrong and Got It, on the sides a \
                swipe sends the card. Swipe right before turning a card to mark it known at once. Wrong cards come \
                back at the end.
                """,
            systemImage: "rectangle.on.rectangle.angled",
            color: DesignSystem.Color.purple
        ) {
            go.open(.srsStudy)
        }
    }
}
#endif
