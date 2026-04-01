#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_Service
import Geografy_Core_DesignSystem
import SwiftUI

struct CustomQuizPreviewScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CountryDataService.self) private var countryDataService

    let quiz: CustomQuiz
    let onSave: (CustomQuiz) -> Void

    var body: some View {
        scrollContent
            .background(DesignSystem.Color.background)
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) { saveButton }
    }
}

// MARK: - Subviews
private extension CustomQuizPreviewScreen {
    var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                headerCard
                countriesSection
                questionTypesSection
                difficultySection
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }
}

// MARK: - Header Card
private extension CustomQuizPreviewScreen {
    var headerCard: some View {
        CustomQuizCard(quiz: quiz)
    }
}

// MARK: - Countries Section
private extension CustomQuizPreviewScreen {
    var countriesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Countries", icon: "globe")

            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(selectedCountries.prefix(5)) { country in
                    CountryRowView(
                        country: country,
                        isFavorite: false,
                        showStats: false,
                        showContinent: true,
                    )
                }

                if selectedCountries.count > 5 {
                    moreCountriesLabel
                }
            }
        }
    }

    var selectedCountries: [Country] {
        countryDataService.countries
            .filter { quiz.countryCodes.contains($0.code) }
            .sorted { $0.name < $1.name }
    }

    var moreCountriesLabel: some View {
        Text("+ \(selectedCountries.count - 5) more countries")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

// MARK: - Question Types Section
private extension CustomQuizPreviewScreen {
    var questionTypesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Question Types", icon: "list.bullet")

            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(quiz.questionTypes) { type in
                    questionTypeRow(type)
                }
            }
        }
    }

    func questionTypeRow(_ type: QuizType) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: type.icon)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: 28)

            Text(type.displayName)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Spacer(minLength: 0)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Difficulty Section
private extension CustomQuizPreviewScreen {
    var difficultySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Difficulty", icon: "speedometer")

            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: quiz.difficulty.icon)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text(quiz.difficulty.displayName)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(quiz.difficulty.subtitle)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }

                Spacer(minLength: 0)
            }
            .padding(DesignSystem.Spacing.sm)
            .background(DesignSystem.Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        }
    }
}

// MARK: - Save Button
private extension CustomQuizPreviewScreen {
    var saveButton: some View {
        GlassButton("Save Quiz", systemImage: "checkmark", fullWidth: true) {
            onSave(quiz)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}
#endif
