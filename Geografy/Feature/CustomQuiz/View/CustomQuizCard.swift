import SwiftUI
import GeografyDesign

struct CustomQuizCard: View {
    let quiz: CustomQuiz

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            gradient
            backgroundIcon
            cardInfo
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .shadow(color: accentColor.opacity(0.4), radius: 12, y: 5)
    }
}

// MARK: - Subviews
private extension CustomQuizCard {
    var gradient: some View {
        LinearGradient(
            colors: [accentColor, accentColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing,
        )
    }

    var backgroundIcon: some View {
        Image(systemName: quiz.icon)
            .font(DesignSystem.IconSize.hero)
            .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.10))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .offset(x: 24, y: -12)
            .clipped()
    }

    var cardInfo: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Spacer(minLength: 0)
            quizName
            statsRow
        }
        .padding(DesignSystem.Spacing.sm)
    }

    var quizName: some View {
        Text(quiz.name)
            .font(DesignSystem.Font.headline)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .lineLimit(1)
    }

    var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            statPill(
                text: "\(quiz.countryCodes.count) countries",
                icon: "globe",
            )
            statPill(
                text: quiz.difficulty.displayName,
                icon: quiz.difficulty.icon,
            )
        }
    }
}

// MARK: - Helpers
private extension CustomQuizCard {
    var accentColor: Color {
        let codeValue = quiz.name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return DesignSystem.Color.mapColors[codeValue % DesignSystem.Color.mapColors.count]
    }

    func statPill(text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
            Text(text)
                .font(DesignSystem.Font.caption2)
        }
        .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.9))
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, 4)
        .background(DesignSystem.Color.onAccent.opacity(0.18))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(DesignSystem.Color.onAccent.opacity(0.25), lineWidth: 1)
        )
    }
}
