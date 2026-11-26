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
            speedRunPlainField,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var speedRunPlainField: BuildNote {
        BuildNote(
            commit: "2e031794",
            title: "Speed Run field without the keyboard glyph",
            howToTest: """
                Start a Speed Run: the field reads Name a country with no keyboard icon before it, like the other \
                games' answer fields.
                """,
            systemImage: "character.cursor.ibeam",
            color: DesignSystem.Color.pink
        ) {
            go.open(.speedRun)
        }
    }
}
#endif
