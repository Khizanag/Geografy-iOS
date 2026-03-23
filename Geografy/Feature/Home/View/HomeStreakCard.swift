import SwiftUI

struct HomeStreakCard: View {
    @Environment(HapticsService.self) private var hapticsService

    let streak: Int
    let onStartQuiz: () -> Void

    var body: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                streakIcon
                streakInfo
                Spacer()
                quizButton
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews

private extension HomeStreakCard {
    var streakIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "FF6B00").opacity(0.25), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 32
                    )
                )
                .frame(width: 56, height: 56)
            Text(streak > 0 ? "🔥" : "💤")
                .font(.system(size: 28))
        }
    }

    var streakInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(streak > 0 ? "\(streak) day streak!" : "Start your streak")
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(streak > 0 ? "Keep exploring to maintain it" : "Play a quiz to begin")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var quizButton: some View {
        Button {
            hapticsService.impact(.medium)
            onStartQuiz()
        } label: {
            Text("Play")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(DesignSystem.Color.accent, in: Capsule())
        }
        .buttonStyle(PressButtonStyle())
    }
}
