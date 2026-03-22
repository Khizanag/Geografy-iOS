import SwiftUI

struct TravelCountryPickerSheet: View {
    @Environment(TravelService.self) private var travelService

    let countries: [Country]
    @Binding var isPresented: Bool

    @State private var searchText = ""
    @State private var selectedCountry: Country?

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Color.background.ignoresSafeArea()
                countryList
            }
            .navigationTitle("Add Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { doneButton }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search countries…"
            )
        }
        .sheet(item: $selectedCountry) { country in
            TravelStatusPickerSheet(
                country: country,
                isPresented: Binding(
                    get: { selectedCountry != nil },
                    set: { if !$0 { selectedCountry = nil } }
                )
            )
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Subviews

private extension TravelCountryPickerSheet {
    var countryList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(filteredCountries) { country in
                    pickerRow(country)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
    }

    func pickerRow(_ country: Country) -> some View {
        let status = travelService.status(for: country.code)
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            selectedCountry = country
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    FlagView(countryCode: country.code, height: 36)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .frame(width: 54)
                    countryInfo(country)
                    Spacer(minLength: 0)
                    trailingView(status)
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    func countryInfo(_ country: Country) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(country.name)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(country.continent.displayName)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    func trailingView(_ status: TravelStatus?) -> some View {
        Group {
            if let status {
                statusBadge(status)
            } else {
                Image(systemName: "plus.circle")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
    }

    func statusBadge(_ status: TravelStatus) -> some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.system(size: 9))
            Text(status.shortLabel)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(status.color.opacity(0.15), in: Capsule())
    }

    @ToolbarContentBuilder
    var doneButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Done") { isPresented = false }
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }
}

// MARK: - Data

private extension TravelCountryPickerSheet {
    var filteredCountries: [Country] {
        let sorted = countries.sorted { $0.name < $1.name }
        guard !searchText.isEmpty else { return sorted }
        return sorted.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}
