import SwiftUI

struct LanguageExplorerScreen: View {
    @State private var searchQuery = ""
    @State private var selectedLanguage: Language?
    @State private var showingDetail = false

    private let languageService = LanguageService()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                searchBar
                languageContent
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Language Explorer")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDetail) {
            if let language = selectedLanguage {
                NavigationStack {
                    LanguageDetailView(language: language, maxSpeakers: languageService.maxSpeakers)
                }
                .presentationDetents([.large])
            }
        }
    }
}

// MARK: - Subviews

private extension LanguageExplorerScreen {
    var searchBar: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DesignSystem.Color.textSecondary)
            TextField("Search languages...", text: $searchQuery)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    @ViewBuilder
    var languageContent: some View {
        if searchQuery.isEmpty {
            groupedLanguages
        } else {
            filteredLanguages
        }
    }

    var groupedLanguages: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ForEach(languageService.families, id: \.self) { family in
                let familyLanguages = languageService.languages(in: family)
                if !familyLanguages.isEmpty {
                    familySection(family: family, languages: familyLanguages)
                }
            }
        }
    }

    var filteredLanguages: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(languageService.languages(matching: searchQuery)) { language in
                languageRow(language)
            }
        }
    }

    func familySection(family: String, languages: [Language]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: family, icon: "character.book.closed.fill")
            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(languages) { language in
                    languageRow(language)
                }
            }
        }
    }

    func languageRow(_ language: Language) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                languageRowIcon(language)
                languageRowInfo(language)
                Spacer()
                speakerBadge(language)
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .padding(DesignSystem.Spacing.md)
        }
        .onTapGesture {
            selectedLanguage = language
            showingDetail = true
        }
        .buttonStyle(PressButtonStyle())
    }

    func languageRowIcon(_ language: Language) -> some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.purple.opacity(0.15))
                .frame(width: 44, height: 44)
            Text(String(language.nativeName.prefix(1)))
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(DesignSystem.Color.purple)
        }
    }

    func languageRowInfo(_ language: Language) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(language.name)
                .font(DesignSystem.Font.headline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(language.nativeName)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    func speakerBadge(_ language: Language) -> some View {
        Text("\(language.speakerCount)M")
            .font(DesignSystem.Font.caption)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.purple)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, 3)
            .background(DesignSystem.Color.purple.opacity(0.12), in: Capsule())
    }
}
