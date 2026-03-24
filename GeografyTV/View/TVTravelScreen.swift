import SwiftUI

struct TVTravelScreen: View {
    @Environment(TravelService.self) private var travelService

    let countryDataService: CountryDataService

    @State private var selectedFilter: TravelFilter = .all

    private var displayedCountries: [Country] {
        let countries = countryDataService.countries.sorted { $0.name < $1.name }
        switch selectedFilter {
        case .all:
            return countries
        case .visited:
            return countries.filter { travelService.status(for: $0.code) == .visited }
        case .wantToVisit:
            return countries.filter { travelService.status(for: $0.code) == .wantToVisit }
        case .notVisited:
            return countries.filter { travelService.status(for: $0.code) == nil }
        }
    }

    var body: some View {
        List {
            Section {
                statsRow

                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TravelFilter.allCases) { filter in
                        Text(filter.displayName)
                            .tag(filter)
                    }
                }
            }

            Section("\(displayedCountries.count) countries") {
                ForEach(displayedCountries) { country in
                    countryRow(country)
                }
            }
        }
        .navigationTitle("Travel Tracker")
    }
}

// MARK: - Subviews

private extension TVTravelScreen {
    var statsRow: some View {
        HStack(spacing: 40) {
            VStack(spacing: 4) {
                Text("\(travelService.visitedCodes.count)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.success)
                Text("Visited")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 4) {
                Text("\(travelService.wantToVisitCodes.count)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("Want to Visit")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 4) {
                let percentage = Int(Double(travelService.visitedCodes.count) / Double(max(countryDataService.countries.count, 1)) * 100)
                Text("\(percentage)%")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.warning)
                Text("World Covered")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    func countryRow(_ country: Country) -> some View {
        HStack(spacing: 20) {
            FlagView(countryCode: country.code, height: 36)

            Text(country.name)
                .font(.system(size: 20))

            Spacer()

            statusMenu(for: country)
        }
    }

    func statusMenu(for country: Country) -> some View {
        let currentStatus = travelService.status(for: country.code)
        return Menu {
            Button {
                travelService.set(status: .visited, for: country.code)
            } label: {
                Label("Visited", systemImage: currentStatus == .visited ? "checkmark.circle.fill" : "airplane.departure")
            }

            Button {
                travelService.set(status: .wantToVisit, for: country.code)
            } label: {
                Label("Want to Visit", systemImage: currentStatus == .wantToVisit ? "checkmark.circle.fill" : "mappin.and.ellipse")
            }

            if currentStatus != nil {
                Button(role: .destructive) {
                    travelService.set(status: nil, for: country.code)
                } label: {
                    Label("Clear", systemImage: "xmark.circle")
                }
            }
        } label: {
            Text(currentStatus?.rawValue.capitalized ?? "Not Set")
                .font(.system(size: 18))
                .foregroundStyle(statusColor(currentStatus))
        }
    }

    func statusColor(_ status: TravelStatus?) -> Color {
        switch status {
        case .visited: DesignSystem.Color.success
        case .wantToVisit: DesignSystem.Color.accent
        case nil: DesignSystem.Color.textTertiary
        }
    }
}

// MARK: - Filter

enum TravelFilter: String, CaseIterable, Identifiable {
    case all
    case visited
    case wantToVisit
    case notVisited

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: "All Countries"
        case .visited: "Visited"
        case .wantToVisit: "Want to Visit"
        case .notVisited: "Not Visited"
        }
    }
}
