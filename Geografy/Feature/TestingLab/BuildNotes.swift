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
            speedRunGlassRows,
            speedRunFieldBar,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var speedRunGlassRows: BuildNote {
        BuildNote(
            commit: "fb1ce5cc",
            title: "Named countries point at the map",
            howToTest: """
                In a Speed Run with Show Map on, name a few countries: each is a glass capsule. Tap one: it turns \
                pink and its country fills pink on the map. Tap it again to let it go.
                """,
            systemImage: "hand.tap",
            color: DesignSystem.Color.pink
        ) {
            go.open(.speedRun)
        }
    }

    var speedRunFieldBar: BuildNote {
        BuildNote(
            commit: "d214c367",
            title: "Speed Run field floats over the list",
            howToTest: """
                Name enough countries to fill the list: the rows scroll under the field, softly blurred at the \
                edge as under any bar, with no solid band behind the field.
                """,
            systemImage: "keyboard",
            color: DesignSystem.Color.pink
        ) {
            go.open(.speedRun)
        }
    }
}
#endif
