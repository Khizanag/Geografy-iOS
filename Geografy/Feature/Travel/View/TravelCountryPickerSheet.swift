import GeografyCore
import GeografyDesign
import SwiftUI

struct TravelCountryPickerSheet: View {
    @Environment(AchievementService.self) private var achievementService
    @Environment(HapticsService.self) private var hapticsService
    @Environment(TravelService.self) private var travelService
    @Environment(XPService.self) private var xpService

    let countries: [Country]
    @Binding var isPresented: Bool
    var preferredStatus: TravelStatus? = nil

    @State private var searchText = ""
    @State private var selectedCountry: Country?

    var body: some View {
        countryList
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search countries…"
            )
            .toolbar { toolbarContent }
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
        let currentStatus = travelService.status(for: country.code)
        let isAlreadyInList = preferredStatus != nil && currentStatus == preferredStatus
        return Button {
            hapticsService.impact(.light)
            if let status = preferredStatus {
                guard !isAlreadyInList else { return }
                travelService.set(status: status, for: country.code)
                awardTravelXP(for: status, countryCode: country.code)
                checkTravelAchievements()
            } else {
                selectedCountry = country
            }
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    FlagView(countryCode: country.code, height: 36)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .frame(width: 54)
                    countryInfo(country)
                    Spacer(minLength: 0)
                    trailingView(currentStatus, isAlreadyInList: isAlreadyInList)
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

    @ViewBuilder
    func trailingView(_ status: TravelStatus?, isAlreadyInList: Bool) -> some View {
        if isAlreadyInList {
            Image(systemName: "checkmark.circle.fill")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(preferredStatus?.color ?? DesignSystem.Color.accent)
        } else if let status {
            statusBadge(status)
        } else {
            Image(systemName: "plus.circle")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    func statusBadge(_ status: TravelStatus) -> some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(DesignSystem.Font.nano)
            Text(status.shortLabel)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(status.color.opacity(0.15), in: Capsule())
    }
}

// MARK: - Toolbar
private extension TravelCountryPickerSheet {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Done") { isPresented = false }
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }
}

// MARK: - Helpers
private extension TravelCountryPickerSheet {
    var navigationTitle: String {
        if let status = preferredStatus {
            return "Add to \(status.label)"
        }
        return "Add Country"
    }

    var filteredCountries: [Country] {
        let sorted = countries.sorted { $0.name < $1.name }
        guard !searchText.isEmpty else { return sorted }
        return sorted.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

// MARK: - Actions
private extension TravelCountryPickerSheet {
    func awardTravelXP(for status: TravelStatus, countryCode: String) {
        let key = "travel_xp_awarded"
        var awarded = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        let entryKey = "\(countryCode):\(status.rawValue)"
        guard !awarded.contains(entryKey) else { return }
        awarded.insert(entryKey)
        UserDefaults.standard.set(Array(awarded), forKey: key)
        switch status {
        case .visited:
            xpService.award(20, source: .travelVisited)
        case .wantToVisit:
            xpService.award(5, source: .travelWantToVisit)
        }
    }

    func checkTravelAchievements() {
        achievementService.checkTravelAchievements(
            visitedCount: travelService.visitedCodes.count,
            wantCount: travelService.wantToVisitCodes.count
        )
    }
}
