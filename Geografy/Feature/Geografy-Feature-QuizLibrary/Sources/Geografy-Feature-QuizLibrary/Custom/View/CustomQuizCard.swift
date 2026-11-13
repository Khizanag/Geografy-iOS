#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public struct CustomQuizCard: View {
    // MARK: - Properties
    public let quiz: CustomQuiz

    // MARK: - Body
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            gradient
            backgroundIcon
            cardInfo
        }
        .frame(minHeight: 140)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
        .shadow(color: accentColor.opacity(0.4), radius: 12, y: 5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(quiz.name)
        .accessibilityValue("\(quiz.countryCodes.count) countries, \(quiz.questionTypes.count) question types")
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
            .accessibilityHidden(true)
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
            .lineLimit(2)
            .minimumScaleFactor(0.8)
    }

    var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            InfoPill("\(quiz.countryCodes.count) countries", systemImage: "globe", style: .onColor)
            InfoPill("\(quiz.questionTypes.count) types", systemImage: "list.bullet", style: .onColor)
        }
    }
}

// MARK: - Helpers
private extension CustomQuizCard {
    var accentColor: Color {
        let codeValue = quiz.name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return DesignSystem.Color.mapColors[codeValue % DesignSystem.Color.mapColors.count]
    }
}
#endif
