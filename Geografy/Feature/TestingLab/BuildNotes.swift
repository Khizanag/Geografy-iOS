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
            sharedChips,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var sharedChips: BuildNote {
        BuildNote(
            commit: "17244c2e",
            title: "One filter chip everywhere",
            howToTest: """
                Compare the chips in Achievements, Travel, Timeline, Landmarks, and Quiz Packs: all are glass \
                capsules, and the chosen one is prominent glass in its colour. Travel's chosen chip shows its \
                count. Timeline's Continent and Event Type open menus. Each choice plays a light tick.
                """,
            systemImage: "capsule.on.rectangle",
            color: DesignSystem.Color.blue
        ) {
            go.open(.achievements)
        }
    }
}
#endif
