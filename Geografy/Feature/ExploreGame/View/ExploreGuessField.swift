import SwiftUI

/// Search field with autocomplete for guessing a country.
struct ExploreGuessField: View {
    @State private var query = ""
    @FocusState private var isFocused: Bool

    let suggestions: [Country]
    let onSearch: (String) -> Void
    let onSubmit: (Country) -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            if !filteredSuggestions.isEmpty, isFocused {
                suggestionList
            }
            searchField
        }
    }
}

// MARK: - Subviews
private extension ExploreGuessField {
    var searchField: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textTertiary)

            TextField("Guess the country...", text: $query)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .focused($isFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .onChange(of: query) { _, newValue in
                    onSearch(newValue)
                }
                .onSubmit {
                    submitTopSuggestion()
                }

            if !query.isEmpty {
                clearButton
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    var clearButton: some View {
        Button {
            query = ""
            onSearch("")
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .buttonStyle(.plain)
    }

    var suggestionList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredSuggestions.prefix(6)) { country in
                    suggestionRow(for: country)
                }
            }
        }
        .frame(maxHeight: 240)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .padding(.top, DesignSystem.Spacing.xxs)
    }

    func suggestionRow(for country: Country) -> some View {
        Button {
            selectCountry(country)
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(countryCode: country.code, height: 20)

                Text(country.name)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Actions
private extension ExploreGuessField {
    func selectCountry(_ country: Country) {
        query = ""
        isFocused = false
        onSearch("")
        onSubmit(country)
    }

    func submitTopSuggestion() {
        guard let first = filteredSuggestions.first else { return }
        selectCountry(first)
    }
}

// MARK: - Helpers
private extension ExploreGuessField {
    var filteredSuggestions: [Country] {
        guard !query.isEmpty else { return [] }
        return suggestions
    }
}
