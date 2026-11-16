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
        [testBadges, checklistSheet, redRemove, testingLab, levelUp, quizTiles, savedMap]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var testBadges: BuildNote {
        BuildNote(
            commit: "78acbcdb",
            title: "Test badges on hub tiles",
            howToTest: """
                Each tile has an orange glass bubble half over its corner, on top of the glass. Tap one: \
                that screen's checklist opens.
                """,
            systemImage: "ladybug.fill",
            color: DesignSystem.Color.orange
        ) {
            go.enableTestingMode()
            go.selectTab(.profile)
        }
    }

    var checklistSheet: BuildNote {
        BuildNote(
            commit: "f928b173",
            title: "Test checklist sheet",
            howToTest: """
                Tick checks: the count and bar update, and turn green when all pass. Close and reopen: \
                ticks stay. Open goes to the screen; Uncheck All clears.
                """,
            systemImage: "checklist",
            color: DesignSystem.Color.blue
        ) {
            go.enableTestingMode()
            go.selectTab(.profile)
        }
    }

    var redRemove: BuildNote {
        BuildNote(
            commit: "ac42a0f1",
            title: "Red Remove in menus",
            howToTest: """
                Pick two countries, then long-press one: Remove's icon and label are both red. \
                Same on a recent search chip.
                """,
            systemImage: "arrow.left.arrow.right",
            color: DesignSystem.Color.blue
        ) {
            go.open(.compare)
        }
    }

    var testingLab: BuildNote {
        BuildNote(
            commit: "479ea4f4",
            title: "Testing Lab",
            howToTest: "Shake the phone to open it. Rows have Settings-style icons, and every reset row is red.",
            systemImage: "flask.fill",
            color: DesignSystem.Color.orange
        )
    }

    var levelUp: BuildNote {
        BuildNote(
            commit: "f7e97b2a",
            title: "Level-up celebration",
            howToTest: """
                A glass card with the tier badge, the level's title, and progress to the next level. \
                In Dark Mode the screen behind darkens.
                """,
            systemImage: "sparkles",
            color: DesignSystem.Color.indigo
        ) {
            go.showLevelUp()
        }
    }

    var quizTiles: BuildNote {
        BuildNote(
            commit: "a07891b0",
            title: "Quiz type tiles",
            howToTest: "Every type's name fits, with no extra space before Flag Quiz's icon.",
            systemImage: "square.grid.2x2.fill",
            color: DesignSystem.Color.purple
        ) {
            go.open(.quiz)
        }
    }

    var savedMap: BuildNote {
        BuildNote(
            commit: "a78a6c5d",
            title: "Saved map",
            howToTest: """
                The map opens without a wait from the second launch on. Clear Saved Map in the lab, \
                relaunch: the first open is slower again.
                """,
            systemImage: "map.fill",
            color: DesignSystem.Color.blue
        ) {
            go.selectTab(.map)
        }
    }
}
#endif
