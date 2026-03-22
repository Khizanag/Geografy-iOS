import SwiftUI

struct ExploreGameRulesSheet: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    rulesSection(
                        icon: "lightbulb.fill",
                        title: "How to Play",
                        items: [
                            "You'll receive progressive clues about a mystery country",
                            "Use the clues to guess which country it is",
                            "Type the country name and select from suggestions",
                        ]
                    )
                    rulesSection(
                        icon: "star.fill",
                        title: "Scoring",
                        items: [
                            "Start with 1,000 points",
                            "Each new clue revealed costs 200 points",
                            "Each wrong guess costs 100 points",
                            "Guess early with fewer clues for a higher score!",
                        ]
                    )
                    rulesSection(
                        icon: "list.number",
                        title: "Clue Order",
                        items: [
                            "1. Continent (free)",
                            "2. Population range (-200 pts)",
                            "3. Flag colors described (-200 pts)",
                            "4. Capital first letter (-200 pts)",
                            "5. Neighboring countries (-200 pts)",
                        ]
                    )
                }
                .padding(DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("How to Play")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CircleCloseButton()
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Subviews

private extension ExploreGameRulesSheet {
    func rulesSection(
        icon: String,
        title: String,
        items: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: title, icon: icon)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: DesignSystem.Spacing.xs) {
                        Circle()
                            .fill(DesignSystem.Color.accent)
                            .frame(width: 5, height: 5)
                            .padding(.top, 6)
                        Text(item)
                            .font(DesignSystem.Font.subheadline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                    }
                }
            }
        }
    }
}
