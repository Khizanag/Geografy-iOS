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
        [emptyStates, countryLists, liquidGlass, forms, achievementCount, tabsInBar]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var emptyStates: BuildNote {
        BuildNote(
            commit: "595da86f",
            title: "Empty states with a way out",
            howToTest: """
                In Timeline, set a filter that hides every event: Clear Filters brings them back. A quiz with \
                no questions for its region offers Choose a Region.
                """,
            systemImage: "tray",
            color: DesignSystem.Color.blue
        ) {
            go.open(.timeline)
        }
    }

    var countryLists: BuildNote {
        BuildNote(
            commit: "4ec35d45",
            title: "Countries listed in one card",
            howToTest: """
                Travel, an organization's members, a continent's countries, and Speed Run's missed list show \
                one card with dividers instead of a card per country. Long lists scroll smoothly.
                """,
            systemImage: "list.bullet.rectangle",
            color: DesignSystem.Color.teal
        ) {
            go.open(.travel)
        }
    }

    var liquidGlass: BuildNote {
        BuildNote(
            commit: "c2d8e35c",
            title: "Glass only where it floats",
            howToTest: """
                The timeline slider, map headers, and achievement banner are Liquid Glass; Leaderboards and \
                the multiplayer lobby use plain cards. Stats everywhere use the same tile.
                """,
            systemImage: "square.on.square",
            color: DesignSystem.Color.indigo
        ) {
            go.open(.timeline)
        }
    }

    var forms: BuildNote {
        BuildNote(
            commit: "18ad2101",
            title: "One text field and a checkmark to save",
            howToTest: """
                Add a travel journal entry: title and notes share one field style, and Save is the checkmark \
                at the top, greyed until a country is chosen.
                """,
            systemImage: "square.and.pencil",
            color: DesignSystem.Color.purple
        ) {
            go.open(.travel)
        }
    }

    var achievementCount: BuildNote {
        BuildNote(
            commit: "395505bd",
            title: "Achievement counts agree",
            howToTest: """
                Profile's achievement count matches the Unlocked tile on the Achievements screen.
                """,
            systemImage: "trophy.fill",
            color: DesignSystem.Color.warning
        ) {
            go.open(.achievements)
        }
    }

    var tabsInBar: BuildNote {
        BuildNote(
            commit: "232ed46c",
            title: "Tabs in the bar",
            howToTest: """
                World Facts and Time Zones switch tabs from the navigation bar, like Explore. Pin Drop and \
                Map Puzzle pick regions with the same tiles as the quiz.
                """,
            systemImage: "rectangle.split.3x1",
            color: DesignSystem.Color.pink
        ) {
            go.open(.worldFacts)
        }
    }
}
#endif
