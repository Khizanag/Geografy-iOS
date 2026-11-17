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
        [smoothMaps, tapRedraw, fasterLaunch, fasterSearch]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var smoothMaps: BuildNote {
        BuildNote(
            commit: "0244d243",
            title: "Every map pans smoothly",
            howToTest: """
                Pan and pinch the Travel map, an organization's map, and the Historical map: they move as \
                smoothly as the main map, pinch around your fingers, and stop at the edge of the world.
                """,
            systemImage: "hand.draw.fill",
            color: DesignSystem.Color.teal
        ) {
            go.open(.travel)
        }
    }

    var tapRedraw: BuildNote {
        BuildNote(
            commit: "9dba2923",
            title: "Selecting a country is instant",
            howToTest: """
                On the main map, tap country after country: the outline moves at once. Turn names on and pan: \
                they slide with the map; pinch and they resize.
                """,
            systemImage: "hand.tap.fill",
            color: DesignSystem.Color.blue
        ) {
            go.selectTab(.map)
        }
    }

    var fasterLaunch: BuildNote {
        BuildNote(
            commit: "9106b6b5",
            title: "Lighter launch",
            howToTest: """
                Quit and reopen the app: the map appears without a hitch. Map colors, flags, sound, and speech \
                are now prepared off the main thread or when first needed.
                """,
            systemImage: "bolt.fill",
            color: DesignSystem.Color.warning
        ) {
            go.selectTab(.map)
        }
    }

    var fasterSearch: BuildNote {
        BuildNote(
            commit: "3bd4c65f",
            title: "Search keeps up with typing",
            howToTest: """
                Type quickly in Search: results update on every keystroke with no lag.
                """,
            systemImage: "magnifyingglass",
            color: DesignSystem.Color.purple
        ) {
            go.open(.search)
        }
    }
}
#endif
