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
            labelsToggle,
            pinDropPanning,
            localPlayPinDrop,
            localPlayQuizTypes,
            localPlayNames,
            localPlayLeaving,
            soundEffects,
        ]
    }
}

// MARK: - Notes
private extension BuildNotes {
    var labelsToggle: BuildNote {
        BuildNote(
            commit: "2673153c",
            title: "Native labels toggle",
            howToTest: """
                Open the World Map and tap Aa. While labels show, it's a green prominent glass button of its own; \
                tap again and it goes back to a plain bar button next to More.
                """,
            systemImage: "textformat",
            color: DesignSystem.Color.accent
        ) {
            go.selectTab(.map)
        }
    }

    var pinDropPanning: BuildNote {
        BuildNote(
            commit: "35c45d3d",
            title: "Pan to every edge in Pin Drop",
            howToTest: """
                Start Pin Drop on the World, zoom in a lot, and pan all the way left and right. Alaska, New Zealand, \
                and Japan are now reachable; a pan stops once the region's edge reaches the middle of the screen.
                """,
            systemImage: "arrow.left.and.right",
            color: DesignSystem.Color.orange
        ) {
            go.open(.pinDrop)
        }
    }

    var localPlayPinDrop: BuildNote {
        BuildNote(
            commit: "c4ae246e",
            title: "Pin Drop against each other",
            howToTest: """
                Host, pick Pin Drop, and choose a region. Both of you find the same countries; a chip shows the \
                other player's points and whether they've locked in, Next Round waits for them, and the result \
                compares points.
                """,
            systemImage: "mappin.and.ellipse",
            color: DesignSystem.Color.orange
        ) {
            go.open(.multiplayer)
        }
    }

    var localPlayQuizTypes: BuildNote {
        BuildNote(
            commit: "8197e05e",
            title: "Every quiz type in Local Play",
            howToTest: """
                Host any of the eleven quiz types. Capital and reverse capital questions now show the country or \
                capital, the answers sit at the bottom on glass, and the score bar shows when the other player \
                has answered.
                """,
            systemImage: "rectangle.grid.2x2.fill",
            color: DesignSystem.Color.teal
        ) {
            go.open(.multiplayer)
        }
    }

    var localPlayNames: BuildNote {
        BuildNote(
            commit: "38f165fa",
            title: "Local Play shows your names",
            howToTest: """
                Each of you types a name before Host or Join. The guest sees the host's name under Nearby \
                Hosts, both see each other's name in the lobby and the match, and the guest sees the host's quiz \
                settings change live.
                """,
            systemImage: "person.2.fill",
            color: DesignSystem.Color.teal
        ) {
            go.open(.multiplayer)
        }
    }

    var localPlayLeaving: BuildNote {
        BuildNote(
            commit: "38f165fa",
            title: "Leaving a match tells the other player",
            howToTest: """
                There's no back button any more. In a match, Give Up asks first, then the other phone shows that \
                you gave up. Close a lobby with someone in it: they see it closed. A guest leaving keeps the \
                host's lobby open. After a result, Done leaves and the other result says so.
                """,
            systemImage: "flag.fill",
            color: DesignSystem.Color.orange
        ) {
            go.open(.multiplayer)
        }
    }

    var soundEffects: BuildNote {
        BuildNote(
            commit: "3023329a",
            title: "Games play sounds",
            howToTest: """
                Turn the ring switch on and play a quiz: a right answer chimes, a wrong one plays two low notes, \
                and the result plays a short tune. A new best in Pin Drop, a level up, or an achievement plays a \
                longer one. With the switch on silent, nothing plays.
                """,
            systemImage: "speaker.wave.2.fill",
            color: DesignSystem.Color.blue
        ) {
            go.open(.quiz)
        }
    }
}
#endif
