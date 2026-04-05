import Geografy_Core_DesignSystem
import SwiftUI

struct HomeGeographyFeaturesCard: View {
    // MARK: - Properties
    let onTap: () -> Void

    // MARK: - Body
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
private extension HomeGeographyFeaturesCard {
    var cardIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.blue.opacity(0.25), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 32
                    )
                )
                .frame(width: 56, height: 56)
            Image(systemName: "mountain.2.fill")
                .font(DesignSystem.Font.iconMedium)
                .foregroundStyle(DesignSystem.Color.blue)
        }
    }

    var cardInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Geography Features")
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Mountains, rivers, deserts & lakes")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(2)
        }
    }

    var exploreButton: some View {
        Text("Explore")
            .font(DesignSystem.Font.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(DesignSystem.Color.blue, in: Capsule())
    }
}
