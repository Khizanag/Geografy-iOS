import Geografy_Core_DesignSystem
import SwiftUI

/// Every game's guide: what it's about, how a round plays, and how it scores. Each game's first screen shows its
/// guide through `.gameGuide(_:)`; Flashcards draws its own illustrations in `FlashcardGuideSheet`.
extension GameGuide {
    static let quiz = GameGuide(
        id: "quiz",
        title: String(localized: "Quiz", bundle: .module),
        systemImage: "gamecontroller.fill",
        color: DesignSystem.Color.blue,
        pages: [
            page(
                "Pick Your Quiz",
                "Choose what to be asked about, where, and how hard.",
                step("square.grid.2x2.fill", "Quiz Type", "Flags, capitals, neighbors, landmarks, and more"),
                step("globe.europe.africa.fill", "Region", "The whole world or one continent"),
                step("timer", "Difficulty", "Easy has no timer; Medium gives 15 seconds, Hard 8")
            ),
            page(
                "Answer Your Way",
                "Tap one of four answers, or type it yourself for a bigger challenge.",
                step("list.bullet", "Multiple Choice", "Four answers at the bottom of the screen"),
                step("keyboard", "Typing", "Type the answer; accents and capitals don't matter"),
                step("textformat.abc", "Spelling Bee", "Spell the answer, or skip a hard one")
            ),
            page(
                "Streaks and Arcade",
                "Right answers in a row build a streak. Arcade keeps asking until you run out of lives.",
                step("flame.fill", "Streaks", "Two right in a row starts a streak"),
                step("heart.fill", "Arcade", "Three lives and endless questions"),
                step("rectangle.on.rectangle", "Review", "Practice the ones you missed as flashcards")
            ),
        ]
    )

    static let mapPuzzle = GameGuide(
        id: "mapPuzzle",
        title: String(localized: "Map Puzzle", bundle: .module),
        systemImage: "puzzlepiece.fill",
        color: DesignSystem.Color.purple,
        pages: [
            page(
                "Name the Country",
                "A country lights up on the map. Pick its name from four choices.",
                step("map.fill", "Choose a Region", "The whole world or one continent"),
                step("circle.dashed", "Small Countries", "Tiny ones get a ring so you can find them"),
                step("list.number", "Choose the Rounds", "From 5 to 50; a small continent asks each country once")
            ),
            page(
                "Tips",
                "Shape and neighbors give a country away before its name does.",
                step("scope", "Look at the Shape", "Coastlines and borders are clues"),
                step("person.2.fill", "Check the Neighbors", "Who it borders narrows it down"),
                step("arrow.counterclockwise", "Play Again", "Every round picks new countries")
            ),
        ]
    )

    static let pinDrop = GameGuide(
        id: "pinDrop",
        title: String(localized: "Pin Drop", bundle: .module),
        systemImage: "mappin.and.ellipse",
        color: DesignSystem.Color.orange,
        pages: [
            page(
                "Find It on the Map",
                "We name a country; you tap where it is. A hit is a bullseye, and the closer, the more you score.",
                step("hand.tap.fill", "Drop a Pin", "Tap the map, then lock in your guess"),
                step("arrow.up.left.and.arrow.down.right", "Zoom and Pan", "Pinch and drag to look closer"),
                step("square.dashed", "Borders", "Turn them off for a harder game with its own record")
            ),
            page(
                "Scoring",
                "Up to 1,000 points for accuracy, plus a bonus for speed and streaks.",
                step("target", "Accuracy", "Full marks inside the country, fewer the farther off"),
                step("bolt.fill", "Speed", "Up to 200 more for a quick and accurate pin"),
                step("flame.fill", "Streak", "Excellent rounds in a row add up to 50%")
            ),
        ]
    )

    static let speedRun = GameGuide(
        id: "speedRun",
        title: String(localized: "Speed Run", bundle: .module),
        systemImage: "timer",
        color: DesignSystem.Color.pink,
        pages: [
            page(
                "Name Every Country",
                "Type every country in the region as fast as you can.",
                step("keyboard", "Just Type", "No need to press Return for a name"),
                step("checkmark.circle.fill", "Instant Feedback", "A correct name ticks off as you type it"),
                step("timer", "Race the Clock", "Finish faster for more XP")
            ),
            page(
                "Compete",
                "Your best times go to Game Center, so you can race your friends.",
                step("trophy.fill", "Leaderboards", "See how your times rank against other players"),
                step("map.fill", "Start Small", "A continent is a good first run")
            ),
        ]
    )

    static let wordSearch = GameGuide(
        id: "wordSearch",
        title: String(localized: "Word Search", bundle: .module),
        systemImage: "character.magnify",
        color: DesignSystem.Color.indigo,
        pages: [
            page(
                "Find Hidden Words",
                "Country names and capitals are hidden in a grid of letters. Drag across them to find them.",
                step("hand.draw.fill", "Drag to Select", "Across, down, or diagonally"),
                step("checkmark.circle.fill", "Words Highlight", "Found words turn green in the grid"),
                step("clock.fill", "Race the Clock", "Your time is tracked; try to beat your best")
            ),
            page(
                "Tips",
                "Master the word search with these strategies.",
                step("eye.fill", "Scan Systematically", "Check each row and column one at a time"),
                step("arrow.left.arrow.right", "Words Go Both Ways", "Drag from either end of a word"),
                step("lightbulb.fill", "Stuck?", "Reveal one word, or all of them to end the puzzle")
            ),
        ]
    )

    static let dailyChallenge = GameGuide(
        id: "dailyChallenge",
        title: String(localized: "Daily Challenge", bundle: .module),
        systemImage: "calendar.badge.exclamationmark",
        color: DesignSystem.Color.orange,
        pages: [
            page(
                "A New Challenge Every Day",
                "Everyone gets the same challenge today. It rotates between three games.",
                step("questionmark.circle.fill", "Mystery Country", "Reveal clues and name the country"),
                step("flag.fill", "Flag Sequence", "Name each flag in turn"),
                step("link", "Capital Chain", "Find the country for each capital")
            ),
            page(
                "Scoring and Streaks",
                "You start with 1,000 points. Clues and wrong answers cost some of them.",
                step("star.fill", "Keep Your Points", "Fewer clues and mistakes, higher score"),
                step("flame.fill", "Streak", "Play every day to keep your streak going"),
                step("clock.arrow.circlepath", "Come Back Tomorrow", "A new challenge starts at midnight")
            ),
        ]
    )

    static let localPlay = GameGuide(
        id: "localPlay",
        title: String(localized: "Local Play", bundle: .module),
        systemImage: "person.2.fill",
        color: DesignSystem.Color.teal,
        pages: [
            page(
                "Play Nearby",
                "Play against a friend on another phone. No account or internet needed.",
                step("antenna.radiowaves.left.and.right", "Host", "Pick the game and wait for your friend"),
                step("magnifyingglass", "Join", "Find your friend's game and tap I'm Ready"),
                step("wifi", "Stay Close", "Both phones on the same Wi-Fi or with Bluetooth on")
            ),
            page(
                "Head to Head",
                "Every game plays head to head. You both get the same questions, map, or grid.",
                step("gamecontroller.fill", "Every Game", "Quiz, Map Puzzle, Pin Drop, Speed Run, and Word Search"),
                step("flag.checkered", "Races", "In Speed Run and Word Search, the first to finish wins"),
                step("arrow.counterclockwise", "Rematch", "Ask for another round when it's over")
            ),
        ]
    )
}

// MARK: - Building
private extension GameGuide {
    static func page(_ title: String.LocalizationValue, _ subtitle: String.LocalizationValue, _ steps: GuideStep...)
        -> GuidePage {
        GuidePage(
            title: String(localized: title, bundle: .module),
            subtitle: String(localized: subtitle, bundle: .module),
            steps: steps
        )
    }

    static func step(
        _ icon: String,
        _ title: String.LocalizationValue,
        _ description: String.LocalizationValue
    ) -> GuideStep {
        GuideStep(
            icon: icon,
            title: String(localized: title, bundle: .module),
            description: String(localized: description, bundle: .module)
        )
    }
}
