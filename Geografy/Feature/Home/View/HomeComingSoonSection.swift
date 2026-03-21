import SwiftUI

struct HomeComingSoonSection: View {
    let onItemTap: (String, String) -> Void

    private let features: [(icon: String, title: String, description: String, colors: [Color])] = [
        (
            "person.2.wave.2.fill",
            "Multiplayer Quiz",
            "Challenge friends in real-time",
            [Color(hex: "6C63FF"), Color(hex: "4DABF7")]
        ),
        (
            "calendar.badge.clock",
            "Daily Challenges",
            "Geography puzzles every day",
            [Color(hex: "FF6B6B"), Color(hex: "FFA500")]
        ),
        (
            "trophy.fill",
            "Leaderboards",
            "Compete globally",
            [Color(hex: "F7971E"), Color(hex: "FFD200")]
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader
            featuresGrid
        }
    }
}

// MARK: - Subviews

private extension HomeComingSoonSection {
    var sectionHeader: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(DesignSystem.Color.accent)
                .frame(width: 3, height: 18)
            Text("Coming Soon")
                .font(DesignSystem.Font.title2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var featuresGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: DesignSystem.Spacing.sm
        ) {
            ForEach(features, id: \.title) { feature in
                featureCard(feature)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func featureCard(_ feature: (icon: String, title: String, description: String, colors: [Color])) -> some View {
        Button { onItemTap(feature.title, feature.icon) } label: {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: feature.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: feature.icon)
                    .font(DesignSystem.IconSize.xxLarge)
                    .foregroundStyle(.white.opacity(0.09))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .offset(x: 10, y: -10)
                    .clipped()
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("SOON")
                        .font(DesignSystem.Font.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, DesignSystem.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(.white.opacity(0.2), in: Capsule())
                    Text(feature.title)
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(feature.description)
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(2)
                }
                .padding(DesignSystem.Spacing.sm)
            }
            .frame(height: 128)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        }
        .buttonStyle(GeoPressButtonStyle())
    }
}
