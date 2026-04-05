import Geografy_Core_DesignSystem
import SwiftUI

struct HomeOceanExplorerCard: View {
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
private extension HomeOceanExplorerCard {
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
            Image(systemName: "water.waves")
                .font(DesignSystem.Font.iconMedium)
                .foregroundStyle(DesignSystem.Color.blue)
        }
    }

    var cardInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Ocean Explorer")
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Oceans, seas & their secrets")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(2)
        }
    }

    var exploreButton: some View {
        Text("Dive In")
            .font(DesignSystem.Font.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(DesignSystem.Color.blue, in: Capsule())
    }
}
