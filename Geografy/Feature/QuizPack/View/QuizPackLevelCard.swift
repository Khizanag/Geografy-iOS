import SwiftUI

struct QuizPackLevelCard: View {
    let level: QuizPackLevel
    let stars: Int
    let isLocked: Bool

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            levelNumber
            levelInfo
            Spacer(minLength: 0)
            starDisplay
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
            } else {
                Text(levelNumberText)
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

    var starDisplay: some View {
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
    var circleColor: Color {
        if isLocked {
            DesignSystem.Color.cardBackgroundHighlighted
        } else if stars > 0 {
            DesignSystem.Color.accent
        } else {
            DesignSystem.Color.cardBackgroundHighlighted
        }
    }

    var levelNumberText: String {
        let levelIndex = level.id.split(separator: "_").last
            .flatMap { Int($0) } ?? 1
        return "\(levelIndex)"
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
