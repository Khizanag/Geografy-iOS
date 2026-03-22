import SwiftUI

struct CustomQuizPreviewScreen: View {
    @Environment(\.dismiss) private var dismiss

    let quiz: CustomQuiz
    let onSave: (CustomQuiz) -> Void

    @State private var countryDataService = CountryDataService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    headerCard
                    countriesSection
                    questionTypesSection
                    difficultySection
                }
                .padding(DesignSystem.Spacing.md)
            }
            .safeAreaInset(edge: .bottom) { saveButton }
            .background(DesignSystem.Color.background)
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task { countryDataService.loadCountries() }
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
        Button {
            onSave(quiz)
        } label: {
            Label("Save Quiz", systemImage: "checkmark")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xxs)
        }
        .buttonStyle(.glass)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Toolbar

private extension CustomQuizPreviewScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            CircleCloseButton()
        }
    }
}
