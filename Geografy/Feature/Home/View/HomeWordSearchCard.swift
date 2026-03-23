import SwiftUI

struct HomeWordSearchCard: View {
    @Environment(HapticsService.self) private var hapticsService

    let onTap: () -> Void

    var body: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                cardIcon
                cardInfo
                Spacer()
                playButton
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

private extension HomeWordSearchCard {
    var cardIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.indigo.opacity(0.25), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 32
                    )
                )
                .frame(width: 56, height: 56)
            Image(systemName: "textformat.abc")
                .font(.system(size: 24))
                .foregroundStyle(DesignSystem.Color.indigo)
        }
    }

    var cardInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Geography Word Search")
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Capitals, countries, continents & more")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
    }

    var playButton: some View {
        Text("Play")
            .font(DesignSystem.Font.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(DesignSystem.Color.indigo, in: Capsule())
    }
}
