import SwiftUI
import GeografyDesign
import GeografyCore

struct CustomQuizCountryPicker: View {
    @Environment(\.dismiss) private var dismiss

    let countries: [Country]
    @Binding var selectedCodes: Set<String>

    @State private var searchText = ""
    @State private var selectedContinent: Country.Continent?

    var body: some View {
        VStack(spacing: 0) {
            continentFilter
            selectionBar
            countryList
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("Select Countries")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .searchable(text: $searchText, prompt: "Search countries")
    }
}

// MARK: - Continent Filter
private extension CustomQuizCountryPicker {
    var continentFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                continentChip(nil, label: "All")
                ForEach(displayableContinents, id: \.self) { continent in
                    continentChip(continent, label: continent.displayName)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
    }

    func continentChip(_ continent: Country.Continent?, label: String) -> some View {
        let isSelected = selectedContinent == continent
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedContinent = continent
            }
        } label: {
            Text(label)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(
                    isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textSecondary
                )
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xxs)
                .background(
                    isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    var displayableContinents: [Country.Continent] {
        Country.Continent.allCases.filter { $0 != .antarctica }
    }
}

// MARK: - Selection Bar
private extension CustomQuizCountryPicker {
    var selectionBar: some View {
        HStack {
            Text("\(selectedCodes.count) selected")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)

            Spacer()

            Button("Select All") { selectAllVisible() }
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)

            Text("·")
                .foregroundStyle(DesignSystem.Color.textTertiary)

            Button("None") { deselectAllVisible() }
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(DesignSystem.Color.cardBackground.opacity(0.5))
    }
}

// MARK: - Country List
private extension CustomQuizCountryPicker {
    var countryList: some View {
        List {
            ForEach(filteredCountries) { country in
                countryRow(country)
                    .listRowBackground(DesignSystem.Color.background)
            }
        }
        .listStyle(.plain)
    }

    func countryRow(_ country: Country) -> some View {
        let isSelected = selectedCodes.contains(country.code)
        return Button {
            toggleCountry(country.code)
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(countryCode: country.code, height: 28)
                    .shadow(color: DesignSystem.Color.textPrimary.opacity(0.2), radius: 2, x: 0, y: 1)

                VStack(alignment: .leading, spacing: 2) {
                    Text(country.name)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .lineLimit(1)
                    Text(country.continent.displayName)
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(
                        isSelected ? DesignSystem.Color.accent : DesignSystem.Color.textTertiary
                    )
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Toolbar
private extension CustomQuizCountryPicker {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Done") { dismiss() }
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }
}

// MARK: - Helpers
private extension CustomQuizCountryPicker {
    var filteredCountries: [Country] {
        var result = countries.filter { $0.continent != .antarctica }

        if let continent = selectedContinent {
            result = result.filter { $0.continent == continent }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result.sorted { $0.name < $1.name }
    }

    func toggleCountry(_ code: String) {
        if selectedCodes.contains(code) {
            selectedCodes.remove(code)
        } else {
            selectedCodes.insert(code)
        }
    }

    func selectAllVisible() {
        for country in filteredCountries {
            selectedCodes.insert(country.code)
        }
    }

    func deselectAllVisible() {
        let visibleCodes = Set(filteredCountries.map(\.code))
        selectedCodes.subtract(visibleCodes)
    }
}
