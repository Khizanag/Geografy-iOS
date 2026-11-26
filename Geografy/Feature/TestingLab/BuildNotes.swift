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
            flashcardsRedesign,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var flashcardsRedesign: BuildNote {
        BuildNote(
            commit: "58bffc7f",
            title: "Flashcards, redesigned",
            howToTest: """
                Open Flashcards: pick a card type, region and session size, then Study. Tap a card or Show Answer \
                and watch it turn over in 3D; nothing under it moves. Drag a card: it tilts, a stamp shows the \
                rating, and the card behind grows forward. Throw it, or let go early to see it spring back. Rate \
                one Wrong and it comes back at the end.
                """,
            systemImage: "rectangle.on.rectangle.angled",
            color: DesignSystem.Color.purple
        ) {
            go.open(.srsStudy)
        }
    }
}
#endif
