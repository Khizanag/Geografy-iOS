import Foundation
import GeografyCore

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
        "badges": TestChecklist(items: [
            "All badge categories load",
            "Earned badges show filled state",
            "Locked badges show lock overlay",
            "Tapping badge opens detail sheet",
        ]),
        "dailyChallenge": TestChecklist(items: [
            "New challenge loads each day",
            "Mystery Country clues reveal progressively",
            "Flag Sequence scoring works",
            "Capital Chain answers validate correctly",
            "Result screen shows correct stats",
        ]),
        "exploreGame": TestChecklist(items: [
            "Clues generate for random country",
            "Progressive clue reveal works",
            "Answer validation (correct/incorrect)",
            "Rules sheet opens and closes",
            "Result screen XP award",
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
            "Locked packs show premium badge",
            "Starting a pack opens quiz session",
            "Completion updates pack progress",
        ]),
        "customQuiz": TestChecklist(items: [
            "Quiz builder allows country selection",
            "Custom quiz saves and appears in library",
            "Starting custom quiz works",
            "Delete custom quiz",
        ]),
        "flagGame": TestChecklist(items: [
            "Flag options display correctly",
            "Score increments on correct answer",
            "Game ends after all rounds",
            "Close button dismisses game",
        ]),
        "trivia": TestChecklist(items: [
            "Questions load with 4 options",
            "Correct/incorrect feedback shown",
            "Score tracks correctly",
            "Result screen at end",
        ]),
        "spellingBee": TestChecklist(items: [
            "Flag and hint display correctly",
            "Letter input and validation works",
            "Correct spelling advances to next",
            "Info guide sheet opens",
        ]),
        "landmarkQuiz": TestChecklist(items: [
            "Landmark images load",
            "Answer options display",
            "Score and progress tracking",
            "Result screen",
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
        "borderChallenge": TestChecklist(items: [
            "Country loads with neighbor count",
            "Text input validates guesses",
            "Found neighbors show flag and name",
            "Timer countdown and auto-end",
            "Reveal shows remaining neighbors",
            "Result screen with XP",
        ]),
        "challengeRoom": TestChecklist(items: [
            "Setup screen with difficulty selection",
            "Multi-round challenge flow",
            "Timer per round",
            "Final result and XP",
        ]),
        "countryNicknames": TestChecklist(items: [
            "Nickname list loads",
            "Quiz mode works",
            "Correct/incorrect feedback",
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
        "quotes": TestChecklist(items: [
            "Quotes load and display",
            "Love button toggles favorite",
            "Share button works",
            "Swipe to next quote",
        ]),
        "feed": TestChecklist(items: [
            "Feed items load",
            "Tapping opens detail",
            "Refresh works",
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
        "travelJournal": TestChecklist(items: [
            "Journal entries load",
            "Create new entry with editor",
            "Edit and delete entries",
            "Photos attach correctly",
        ]),
        "travelBucketList": TestChecklist(items: [
            "Bucket list countries load",
            "Add/remove countries",
            "Navigation to country detail",
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
        "themes": TestChecklist(items: [
            "Theme list loads",
            "Selecting theme applies it",
            "Premium themes show lock",
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
