import SwiftUI

struct HomeGeoFeedCard: View {
    @Environment(HapticsService.self) private var hapticsService

    let onTap: () -> Void

    var body: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                feedIcon
                feedInfo
                Spacer()
                exploreButton
            }
            .padding(DesignSystem.Spacing.md)
        }
        .onTapGesture {
            hapticsService.impact(.medium)
            onTap()
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Subviews

private extension HomeGeoFeedCard {
    var feedIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.purple.opacity(0.25), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 32
                    )
                )
                .frame(width: 56, height: 56)
            Image(systemName: "newspaper.fill")
                .font(.system(size: 24))
                .foregroundStyle(DesignSystem.Color.purple)
        }
    }

    var feedInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Geo Feed")
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Discover fascinating geography facts")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
    }

    var exploreButton: some View {
        Text("Explore")
            .font(DesignSystem.Font.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(DesignSystem.Color.purple, in: Capsule())
    }
}
