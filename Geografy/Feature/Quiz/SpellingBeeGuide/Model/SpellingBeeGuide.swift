import Foundation

enum SpellingBeeIllustration: Int, CaseIterable {
    case flagAndType
    case letterFeedback
    case hints
    case scoring
}

enum SpellingBeeGuide {
    static let pages: [GuidePage] = [
        GuidePage(
            title: "See the Flag, Type the Name",
            subtitle: "You'll see a country's flag and continent. Type the country name letter by letter — spelling matters!",
            steps: [
                GuideStep(icon: "flag.fill", title: "Identify the Flag", description: "Look at the flag and continent hint to figure out the country"),
                GuideStep(icon: "keyboard", title: "Type the Name", description: "Start typing — each letter appears in the grid above"),
                GuideStep(icon: "checkmark.circle.fill", title: "Auto-Complete", description: "When every letter is correct, you advance automatically"),
            ]
        ),
        GuidePage(
            title: "Letter-by-Letter Feedback",
            subtitle: "Each letter you type is checked instantly. Green means correct, red means wrong — fix it before moving on.",
            steps: [
                GuideStep(icon: "checkmark.square.fill", title: "Green = Correct", description: "The letter matches the country name at that position"),
                GuideStep(icon: "xmark.square.fill", title: "Red = Wrong", description: "Delete and try a different letter"),
                GuideStep(icon: "space", title: "Spaces Count", description: "Multi-word names like 'New Zealand' include spaces in the grid"),
            ]
        ),
        GuidePage(
            title: "Use Hints Wisely",
            subtitle: "Stuck? Use up to 3 hints — but each one costs points.",
            steps: [
                GuideStep(icon: "textformat", title: "First Letter", description: "Reveals the starting letter of the country name"),
                GuideStep(icon: "building.columns", title: "Capital City", description: "Shows the country's capital as a clue"),
                GuideStep(icon: "person.2", title: "Population", description: "Shows the population to help narrow it down"),
            ]
        ),
        GuidePage(
            title: "Scoring",
            subtitle: "Earn points for each correct answer. Fewer hints = more points!",
            steps: [
                GuideStep(icon: "star.fill", title: "30 Points — No Hints", description: "Maximum score when you spell it without any help"),
                GuideStep(icon: "star.leadinghalf.filled", title: "20 Points — 1 Hint", description: "Each hint used reduces your score by 10 points"),
                GuideStep(icon: "star", title: "10 Points — 2+ Hints", description: "Minimum 10 points for a correct answer"),
            ]
        ),
    ]
}
