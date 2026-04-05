#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import Geografy_Feature_CountryList
import SwiftUI

public struct CustomQuizPreviewScreen: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryDataService

    public let quiz: CustomQuiz
    public let onSave: (CustomQuiz) -> Void

    // MARK: - Body
    public var body: some View {
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
            .sorted(by: \.name)
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
