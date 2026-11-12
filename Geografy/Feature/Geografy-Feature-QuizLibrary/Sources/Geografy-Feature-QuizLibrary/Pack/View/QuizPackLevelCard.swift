import Geografy_Core_DesignSystem
import SwiftUI

public struct QuizPackLevelCard: View {
    // MARK: - Properties
    public let level: QuizPackLevel
    public let stars: Int
    public let isLocked: Bool

    // MARK: - Init
    public init(
        level: QuizPackLevel,
        stars: Int,
        isLocked: Bool
    ) {
        self.level = level
        self.stars = stars
        self.isLocked = isLocked
    }

    // MARK: - Body
    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            levelNumber
            levelInfo
            Spacer(minLength: 0)
            trailingContent
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: DesignSystem.CornerRadius.medium
            )
        )
        .opacity(isLocked ? 0.5 : 1.0)
    }
}

// MARK: - Subviews
private extension QuizPackLevelCard {
    var levelNumber: some View {
        ZStack {
            Circle()
                .fill(circleColor)
                .frame(
                    width: DesignSystem.Size.lg,
                    height: DesignSystem.Size.lg
                )

            if isLocked {
                Image(systemName: "lock.fill")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            } else if isCompleted {
                Image(systemName: "checkmark")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            } else {
                Text("\(level.levelIndex)")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            }
        }
    }

    var levelInfo: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(level.name)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)

            Text("\(level.questionCount) questions")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    @ViewBuilder
    var trailingContent: some View {
        if isCompleted {
            completedBadge
        } else {
            starDisplay
        }
    }

    var starDisplay: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            ForEach(1...3, id: \.self) { index in
                Image(systemName: starIcon(for: index))
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(starColor(for: index))
            }
        }
    }

    var completedBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            ForEach(1...3, id: \.self) { index in
                Image(systemName: starIcon(for: index))
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(starColor(for: index))
            }
        }
    }
}

// MARK: - Helpers
private extension QuizPackLevelCard {
    var isCompleted: Bool {
        stars > 0
    }

    var circleColor: Color {
        if isLocked {
            DesignSystem.Color.cardBackgroundHighlighted
        } else if isCompleted {
            DesignSystem.Color.success
        } else {
            DesignSystem.Color.accent
        }
    }

    func starIcon(for index: Int) -> String {
        index <= stars ? "star.fill" : "star"
    }

    func starColor(for index: Int) -> Color {
        index <= stars
            ? DesignSystem.Color.warning
            : DesignSystem.Color.textTertiary
    }
}
