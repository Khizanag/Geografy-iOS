import Foundation

public struct ExploreGameRuleSection: Identifiable, Sendable {
    public let id = UUID()
    public let icon: String
    public let title: String
    public let items: [String]
}

public enum ExploreGameRules {
    public static let sections: [ExploreGameRuleSection] = [
        ExploreGameRuleSection(
            icon: "lightbulb.fill",
            title: "How to Play",
            items: [
                "You'll receive progressive clues about a mystery country",
                "Use the clues to guess which country it is",
                "Type the country name and select from suggestions",
            ]
        ),
        ExploreGameRuleSection(
            icon: "star.fill",
            title: "Scoring",
            items: [
                "Start with 1,000 points",
                "Each new clue revealed costs 200 points",
                "Each wrong guess costs 100 points",
                "Guess early with fewer clues for a higher score!",
            ]
        ),
        ExploreGameRuleSection(
            icon: "list.number",
            title: "Clue Order",
            items: [
                "1. Continent (free)",
                "2. Population range (-200 pts)",
                "3. Flag colors described (-200 pts)",
                "4. Capital first letter (-200 pts)",
                "5. Neighboring countries (-200 pts)",
            ]
        ),
    ]
}
