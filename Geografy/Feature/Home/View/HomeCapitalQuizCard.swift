import SwiftUI

struct HomeCapitalQuizCard: View {
    @Environment(HapticsService.self) private var hapticsService

    let onTap: () -> Void

    var body: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                quizIcon
                quizInfo
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

private extension HomeCapitalQuizCard {
    var quizIcon: some View {
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
            Image(systemName: "building.columns.fill")
                .font(.system(size: 24))
                .foregroundStyle(DesignSystem.Color.indigo)
        }
    }

    var quizInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Capital City Quiz")
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Test your world capitals knowledge")
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
