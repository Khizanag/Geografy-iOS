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
            birTawil,
            sharedMapFinder,
            editNameFromHeader,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var birTawil: BuildNote {
        BuildNote(
            commit: "76cdfe5f",
            title: "No hole between Egypt and Sudan",
            howToTest: """
                Zoom the map in on Egypt and Sudan: their border runs straight along the 22nd parallel, with no \
                black wedge. Select Sudan: its outline has no loop inside it.
                """,
            systemImage: "map",
            color: DesignSystem.Color.blue
        ) {
            go.selectTab(.map)
        }
    }

    var sharedMapFinder: BuildNote {
        BuildNote(
            commit: "6c46349a",
            title: "Find a Country, shared picker",
            howToTest: """
                On the Map tab, tap the magnifier: the list has letter sections, the A to Z index, and continents, \
                like every country picker, and still lists territories such as Åland. Pick one to fly there.
                """,
            systemImage: "magnifyingglass",
            color: DesignSystem.Color.blue
        ) {
            go.selectTab(.map)
        }
    }

    var editNameFromHeader: BuildNote {
        BuildNote(
            commit: "cc7e4d2d",
            title: "Edit your name from Profile",
            howToTest: """
                Open Profile, then the Profile card, and tap your name card at the top: Edit Profile opens, for a \
                guest too. Change the name and save.
                """,
            systemImage: "pencil",
            color: DesignSystem.Color.blue
        ) {
            go.open(.profile)
        }
    }
}
#endif
