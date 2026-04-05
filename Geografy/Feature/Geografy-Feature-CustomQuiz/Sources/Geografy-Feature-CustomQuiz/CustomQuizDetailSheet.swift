#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

struct CustomQuizDetailSheet: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(CountryDataService.self) private var countryDataService

    let quiz: CustomQuiz
    let onEdit: () -> Void
    let onPlay: () -> Void

    // MARK: - Body
    var body: some View {
        scrollContent
            .background(DesignSystem.Color.background)
            .navigationTitle(quiz.name)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) { playButton }
            .toolbar { toolbarContent }
    }
}

// MARK: - Subviews
private extension CustomQuizDetailSheet {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                CustomQuizCard(quiz: quiz)

                countriesSection

                questionTypesSection

                infoSection
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }
}

// MARK: - Countries
private extension CustomQuizDetailSheet {
    var countriesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Countries", icon: "globe")

            let grouped = Dictionary(
                grouping: selectedCountries,
                by: \.continent,
            )

            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(
                    grouped.keys.sorted { $0.displayName < $1.displayName },
                    id: \.self
                ) { continent in
                    continentRow(continent, count: grouped[continent]?.count ?? 0)
                }
            }
        }
    }

    var selectedCountries: [Country] {
        countryDataService.countries
            .filter { quiz.countryCodes.contains($0.code) }
    }

    func continentRow(_ continent: Country.Continent, count: Int) -> some View {
        HStack {
            Image(systemName: continent.icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: 24)

            Text(continent.displayName)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Spacer()

            Text("\(count)")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }
}

// MARK: - Question Types
private extension CustomQuizDetailSheet {
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

// MARK: - Info
private extension CustomQuizDetailSheet {
    var infoSection: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            infoPill(
                value: "\(quiz.countryCodes.count)",
                label: "Countries",
                icon: "globe",
            )
            infoPill(
                value: "\(quiz.questionTypes.count)",
                label: "Types",
                icon: "list.bullet",
            )
            infoPill(
                value: quiz.createdAt.formatted(.dateTime.month(.abbreviated).day()),
                label: "Created",
                icon: "calendar",
            )
        }
    }

    func infoPill(value: String, label: String, icon: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)

            Text(value)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
        )
    }
}

// MARK: - Play Button
private extension CustomQuizDetailSheet {
    var playButton: some View {
        GlassButton("Play Quiz", systemImage: "play.fill", fullWidth: true) {
            onPlay()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Toolbar
private extension CustomQuizDetailSheet {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
                    .foregroundStyle(DesignSystem.Color.iconPrimary)
            }
        }
    }
}
#endif
