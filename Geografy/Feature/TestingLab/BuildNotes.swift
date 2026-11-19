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
        [localPlayNames, localPlayLeaving, localPlayDiscovery, typeCarouselAlignment, soundEffects, legalLinks]
    }
}

// MARK: - Notes
private extension BuildNotes {
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

    var localPlayDiscovery: BuildNote {
        BuildNote(
            commit: "f0c0b1b2",
            title: "Local Play finds the other phone",
            howToTest: """
                On two phones, open Local Play: one hosts, the other joins. Allow Local Network on both when \
                asked. The host appears under Nearby Hosts on the other phone, and tapping it connects. With \
                Local Network off, the lobby says so and links to Settings.
                """,
            systemImage: "antenna.radiowaves.left.and.right",
            color: DesignSystem.Color.blue
        ) {
            go.open(.multiplayer)
        }
    }

    var typeCarouselAlignment: BuildNote {
        BuildNote(
            commit: "1dd39908",
            title: "Quiz type tiles line up with the page",
            howToTest: """
                Local Play, Host Game: the first quiz type tile starts at the same edge as Quiz Settings and the \
                region cards. Custom Quiz's question types line up the same way.
                """,
            systemImage: "align.horizontal.left.fill",
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

    var legalLinks: BuildNote {
        BuildNote(
            commit: "38f70b7b",
            title: "Privacy Policy and Terms of Service open",
            howToTest: """
                Settings, About: Privacy Policy and Terms of Service open Geografy's own pages instead of a missing \
                page.
                """,
            systemImage: "doc.text.fill",
            color: DesignSystem.Color.indigo
        ) {
            go.open(.settings)
        }
    }
}
#endif
