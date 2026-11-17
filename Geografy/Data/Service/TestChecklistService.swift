#if DEBUG
import Foundation
import Geografy_Core_Common

@Observable
final class TestChecklistService {
    private(set) var checklists: [String: TestChecklist]

    init() {
        checklists = Self.defaultChecklists
    }
}

// MARK: - Model
struct TestChecklist {
    let items: [String]
}

// MARK: - Default Checklists
private extension TestChecklistService {
    static let defaultChecklists: [String: TestChecklist] = [
        "profile": TestChecklist(items: [
            "Profile loads with correct name and avatar",
            "XP bar and level display correctly",
            "Weekly heatmap shows accurate data",
            "Stats section shows correct counts",
        ]),
        "favorites": TestChecklist(items: [
            "Favorited countries appear in list",
            "Unfavoriting removes from list",
            "Tapping navigates to country detail",
            "Empty state shown when no favorites",
        ]),
        "dailyChallenge": TestChecklist(items: [
            "New challenge loads each day",
            "Mystery Country clues reveal progressively",
            "Flag Sequence scoring works",
            "Capital Chain answers validate correctly",
            "Result screen shows correct stats",
        ]),
        "speedRun": TestChecklist(items: [
            "Timer counts up correctly",
            "Country name matching works (including alternates)",
            "Progress bar fills as countries are named",
            "Result screen shows time and count",
            "Game Center score submission",
        ]),
        "multiplayer": TestChecklist(items: [
            "Lobby loads with quiz type and region selection",
            "Match creation and joining works",
            "Round timer and answer submission",
            "Result screen shows winner",
        ]),
        "quizPacks": TestChecklist(items: [
            "Pack list loads with progress",
            "Starting a pack opens quiz session",
            "Completion updates pack progress",
        ]),
        "wordSearch": TestChecklist(items: [
            "Grid generates with hidden words",
            "Drag selection highlights cells",
            "Found words mark green",
            "Pause/continue overlay works",
            "Per-word reveal hint works",
            "Reveal All shows all words",
            "Result banner and footer buttons",
        ]),
        "search": TestChecklist(items: [
            "Search finds countries by name",
            "Search finds capitals",
            "Search finds organizations",
            "Recent searches save and clear",
            "Tapping result navigates to detail",
            "Whole row is tappable",
        ]),
        "compare": TestChecklist(items: [
            "Country picker opens and selects",
            "Both slots fill with country data",
            "Swap button switches countries",
            "Stats comparison displays correctly",
        ]),
        "distanceCalculator": TestChecklist(items: [
            "Two country pickers work",
            "Distance calculates and displays",
            "Swap button works",
            "Close button dismisses",
        ]),
        "currencyConverter": TestChecklist(items: [
            "Currency picker opens",
            "Conversion calculates",
            "Swap currencies button works",
            "Amount input works",
        ]),
        "timeZones": TestChecklist(items: [
            "World clock displays times",
            "Time zone quiz works",
            "UTC offsets shown correctly",
        ]),
        "timeline": TestChecklist(items: [
            "Historical events load",
            "Year picker works",
            "Map view shows borders for selected year",
        ]),
        "orgs": TestChecklist(items: [
            "Organization list loads",
            "Tapping opens detail with member list",
            "Map view shows member countries",
        ]),
        "learningPath": TestChecklist(items: [
            "Learning modules load",
            "Progress tracking works",
            "Module navigation works",
        ]),
        "travel": TestChecklist(items: [
            "Country status picker works (visited/want)",
            "Travel map shows colored countries",
            "Stats update correctly",
        ]),
        "achievements": TestChecklist(items: [
            "Achievement list loads with progress",
            "Completed achievements show filled",
            "Progress bars accurate",
        ]),
        "leaderboards": TestChecklist(items: [
            "Leaderboard categories load",
            "Scores display with rank",
            "Friends list integration",
        ]),
        "srsStudy": TestChecklist(items: [
            "Due cards load",
            "Card flip and rating works",
            "Spaced repetition intervals update",
        ]),
        "settings": TestChecklist(items: [
            "All settings sections load",
            "Toggles persist changes",
            "Testing mode toggle works",
        ]),
    ]
}

// MARK: - Lookup
extension TestChecklistService {
    func checklist(for sheet: String) -> TestChecklist? {
        checklists[sheet]
    }
}
#endif
