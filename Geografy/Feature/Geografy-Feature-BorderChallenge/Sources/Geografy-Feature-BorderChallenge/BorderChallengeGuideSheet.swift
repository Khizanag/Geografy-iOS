import Geografy_Core_DesignSystem
import SwiftUI

struct BorderChallengeGuideSheet: View {
    // MARK: - Body
    var body: some View {
        GuideSheet(pages: Self.pages) { illustration in
            illustrationView(illustration)
        }
    }
}

// MARK: - Pages
private extension BorderChallengeGuideSheet {
    static let pages: [GuidePage] = [
        GuidePage(
            title: "Find the Neighbors",
            subtitle: "Test your knowledge of country borders",
            steps: [
                GuideStep(
                    icon: "globe.americas.fill",
                    title: "Random Country",
                    description: "A country is randomly selected based on your chosen difficulty"
                ),
                GuideStep(
                    icon: "keyboard",
                    title: "Type & Submit",
                    description: "Type the name of a neighboring country and press enter"
                ),
                GuideStep(
                    icon: "checkmark.circle",
                    title: "Find Them All",
                    description: "Correctly named neighbors are revealed on the grid"
                ),
            ]
        ),
        GuidePage(
            title: "Tips & Strategy",
            subtitle: "Maximize your score",
            steps: [
                GuideStep(
                    icon: "lightbulb.fill",
                    title: "Common Names Work",
                    description: "Alternative names are accepted (e.g. 'USA' for United States)"
                ),
                GuideStep(
                    icon: "timer",
                    title: "Watch the Clock",
                    description: "Each difficulty has a different time limit — plan accordingly"
                ),
                GuideStep(
                    icon: "star.fill",
                    title: "Higher Difficulty = More XP",
                    description: "Hard mode gives 3x XP multiplier per correct answer"
                ),
            ]
        ),
    ]
}

// MARK: - Illustration
private extension BorderChallengeGuideSheet {
    @ViewBuilder
    func illustrationView(_ page: Int) -> some View {
        let icons = ["map.fill", "sparkles"]
        let colors: [Color] = [DesignSystem.Color.accent, DesignSystem.Color.warning]
        let index = min(page, icons.count - 1)

        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [colors[index].opacity(0.25), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .frame(width: 100, height: 100)

            Image(systemName: icons[index])
                .font(DesignSystem.Font.displayXS)
                .foregroundStyle(colors[index])
        }
    }
}
