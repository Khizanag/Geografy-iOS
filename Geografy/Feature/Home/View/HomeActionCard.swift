import Geografy_Core_DesignSystem
import SwiftUI

struct HomeActionCard: View {
    let dailyChallengeCompleted: Bool
    let srsCardsDue: Int
    let onDailyChallenge: () -> Void
    let onReviewCards: () -> Void
    let onStartQuiz: () -> Void

    var body: some View {
        Button { action.handler() } label: {
            cardContent
                .padding(DesignSystem.Spacing.md)
                .background { gradientBackground }
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
                .geoShadow(.card)
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Subviews
private extension HomeActionCard {
    var cardContent: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            iconCircle
            textContent
            Spacer()
            chevron
        }
    }

    var iconCircle: some View {
        ZStack {
            Circle()
                .fill(action.color.opacity(0.2))
                .frame(
                    width: DesignSystem.Size.xxl,
                    height: DesignSystem.Size.xxl
                )

            Circle()
                .fill(action.color.opacity(0.08))
                .frame(
                    width: DesignSystem.Size.xxxl,
                    height: DesignSystem.Size.xxxl
                )

            Image(systemName: action.icon)
                .font(DesignSystem.Font.iconLarge)
                .foregroundStyle(action.color)
                .symbolRenderingMode(.hierarchical)
        }
    }

    var textContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(action.title)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text(action.subtitle)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(2)
        }
    }

    var chevron: some View {
        Image(systemName: "chevron.right")
            .font(DesignSystem.Font.iconSmall)
            .fontWeight(.semibold)
            .foregroundStyle(action.color.opacity(0.6))
    }

    var gradientBackground: some View {
        LinearGradient(
            colors: [
                action.color.opacity(0.15),
                action.color.opacity(0.05),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Action Resolution
private extension HomeActionCard {
    struct ActionConfig {
        let icon: String
        let title: String
        let subtitle: String
        let color: Color
        let handler: () -> Void
    }

    var action: ActionConfig {
        if !dailyChallengeCompleted {
            ActionConfig(
                icon: "calendar.badge.clock",
                title: "Daily Challenge",
                subtitle: "Today's challenge is waiting for you",
                color: DesignSystem.Color.indigo,
                handler: onDailyChallenge
            )
        } else if srsCardsDue > 0 {
            ActionConfig(
                icon: "rectangle.on.rectangle.angled",
                title: "Review Cards",
                subtitle: "\(srsCardsDue) flashcard\(srsCardsDue == 1 ? "" : "s") due for review",
                color: DesignSystem.Color.purple,
                handler: onReviewCards
            )
        } else {
            ActionConfig(
                icon: "play.circle.fill",
                title: "Start a Quiz",
                subtitle: "Test your geography knowledge",
                color: DesignSystem.Color.accent,
                handler: onStartQuiz
            )
        }
    }
}
