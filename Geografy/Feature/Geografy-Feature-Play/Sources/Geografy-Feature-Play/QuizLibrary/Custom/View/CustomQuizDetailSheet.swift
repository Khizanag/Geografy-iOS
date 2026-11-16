#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

struct CustomQuizDetailSheet: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let quiz: CustomQuiz
    let onEdit: () -> Void
    let onPlay: () -> Void

    // MARK: - Body
    var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle(quiz.name)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaBar(edge: .bottom) { playButton }
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
                    grouped.keys.sorted(by: \.displayName),
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
        CardView(cornerRadius: DesignSystem.CornerRadius.small) {
            HStack {
                Image(systemName: continent.icon)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .frame(width: 24)
                    .accessibilityHidden(true)

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
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(continent.displayName)
        .accessibilityValue("\(count) countries")
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
        CardView(cornerRadius: DesignSystem.CornerRadius.medium) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: type.icon)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                Text(type.displayName)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Spacer(minLength: 0)
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }
}

// MARK: - Info
private extension CustomQuizDetailSheet {
    var infoSection: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.sm))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.sm))
        return layout {
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
        CardView(cornerRadius: DesignSystem.CornerRadius.medium) {
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .accessibilityHidden(true)

                Text(value)
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Text(label)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(value)
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
