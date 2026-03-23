import SwiftUI

struct HomeDailyChallengeCard: View {
    @Environment(HapticsService.self) private var hapticsService

    let streak: Int
    let hasCompletedToday: Bool
    let onTap: () -> Void

    var body: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                challengeIcon
                challengeInfo
                Spacer()
                actionButton
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

private extension HomeDailyChallengeCard {
    var challengeIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.indigo.opacity(0.28), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 32
                    )
                )
                .frame(width: 56, height: 56)
            Image(systemName: hasCompletedToday ? "checkmark.seal.fill" : "calendar.badge.clock")
                .font(.system(size: 26))
                .foregroundStyle(
                    hasCompletedToday ? DesignSystem.Color.success : DesignSystem.Color.indigo
                )
        }
    }

    var challengeInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Daily Challenge")
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(subtitleText)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
    }

    var actionButton: some View {
        Text(hasCompletedToday ? "Done" : "Play")
            .font(DesignSystem.Font.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(hasCompletedToday ? DesignSystem.Color.success : DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                hasCompletedToday
                    ? DesignSystem.Color.success.opacity(0.15)
                    : DesignSystem.Color.indigo,
                in: Capsule()
            )
    }

    var subtitleText: String {
        if hasCompletedToday {
            return streak > 1 ? "🔥 \(streak) day streak!" : "Completed today"
        }
        return streak > 0 ? "🔥 \(streak) day streak — keep it up!" : "New geography challenge awaits"
    }
}
