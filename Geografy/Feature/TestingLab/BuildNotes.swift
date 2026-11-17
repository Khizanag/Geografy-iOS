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
        [giveUp, achievements, exploredCount, mapFocus, shortcuts, spotlight, currencyCopy]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var giveUp: BuildNote {
        BuildNote(
            commit: "19aeed9d",
            title: "Give Up asks first",
            howToTest: """
                Start a quiz, then the Daily Challenge: each has a red flag that asks before quitting. \
                Flashcards close at once, since every card is already saved.
                """,
            systemImage: "flag.fill",
            color: DesignSystem.Color.error
        ) {
            go.open(.quiz)
        }
    }

    var achievements: BuildNote {
        BuildNote(
            commit: "67d237c8",
            title: "13 achievements now unlock",
            howToTest: """
                Continents, Global Citizen, Org Scholar (all 29 organizations), flashcard mastery, sharing a \
                Daily Challenge, and a full World Speed Run. Check progress on Achievements.
                """,
            systemImage: "trophy.fill",
            color: DesignSystem.Color.warning
        ) {
            go.open(.achievements)
        }
    }

    var exploredCount: BuildNote {
        BuildNote(
            commit: "808bfcc9",
            title: "Explored count on Profile",
            howToTest: """
                The count is the countries whose pages you've opened, including ones from before this build, \
                and goes up as you open new ones. Tapping it opens Countries.
                """,
            systemImage: "globe.europe.africa.fill",
            color: DesignSystem.Color.blue
        ) {
            go.selectTab(.profile)
        }
    }

    var mapFocus: BuildNote {
        BuildNote(
            commit: "fc28afb5",
            title: "Map opens on the country",
            howToTest: "On a country, tap Continent, then Open … Map: the map zooms to that country and selects it.",
            systemImage: "scope",
            color: DesignSystem.Color.blue
        ) {
            go.open(.countries)
        }
    }

    var shortcuts: BuildNote {
        BuildNote(
            commit: "84e57304",
            title: "Shortcuts on a cold launch",
            howToTest: """
                Close Geografy, then run Start Daily Challenge or Start Quiz from Shortcuts or Siri: the app \
                opens right on it.
                """,
            systemImage: "square.2.layers.3d.fill",
            color: DesignSystem.Color.indigo
        )
    }

    var spotlight: BuildNote {
        BuildNote(
            commit: "12a1cbc5",
            title: "Countries in Spotlight",
            howToTest: "Search a country's name from the Home Screen: Geografy's result appears and opens it.",
            systemImage: "magnifyingglass",
            color: DesignSystem.Color.textSecondary
        )
    }

    var currencyCopy: BuildNote {
        BuildNote(
            commit: "6969e9e3",
            title: "Currency tile text",
            howToTest: "Explore ▸ Discover ▸ Tools: the converter says daily rates, not live ones.",
            systemImage: "dollarsign.arrow.circlepath",
            color: DesignSystem.Color.blue
        ) {
            go.selectTab(.explore)
        }
    }
}
#endif
