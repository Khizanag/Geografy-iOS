import SwiftUI
import GeografyDesign
import GeografyCore

struct HomeCountryNicknamesCard: View {
    let onTap: () -> Void

    var body: some View {
        Button { onTap() } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.md) {
                    cardIcon
                    cardInfo
                    Spacer()
                    exploreButton
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Subviews
private extension HomeCountryNicknamesCard {
    var cardIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.orange.opacity(0.25), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 32
                    )
                )
                .frame(width: 56, height: 56)
            Image(systemName: "quote.bubble.fill")
                .font(DesignSystem.Font.iconMedium)
                .foregroundStyle(DesignSystem.Color.orange)
        }
    }

    var cardInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Country Nicknames")
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Discover what each country is called")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(2)
        }
    }

    var exploreButton: some View {
        Text("Discover")
            .font(DesignSystem.Font.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(DesignSystem.Color.orange, in: Capsule())
    }
}
