import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

struct ToolsScreen: View {
    let countryDataService: CountryDataService

    var body: some View {
        List {
            NavigationLink {
                DistanceCalculatorScreen(countryDataService: countryDataService)
            } label: {
                Label("Distance Calculator", systemImage: "ruler.fill")
            }

            NavigationLink {
                CurrencyInfoScreen(countryDataService: countryDataService)
            } label: {
                Label("Currency Info", systemImage: "dollarsign.circle.fill")
            }

            NavigationLink {
                TimeZoneScreen(countryDataService: countryDataService)
            } label: {
                Label("Time Zones", systemImage: "clock.fill")
            }
        }
        .navigationTitle("Tools")
    }
}

// MARK: - Distance Calculator
struct DistanceCalculatorScreen: View {
    let countryDataService: CountryDataService

    @State private var countryA: Country?
    @State private var countryB: Country?
    @State private var showPickerA = false
    @State private var showPickerB = false

    private var selectedPair: (Country, Country)? {
        guard let countryA, let countryB else { return nil }
        return (countryA, countryB)
    }

    var body: some View {
        // swiftlint:disable:next closure_body_length
        Form {
            Section("From") {
                Button {
                    showPickerA = true
                } label: {
                    HStack {
                        if let countryA {
                            FlagView(countryCode: countryA.code, height: 30)
                            Text(countryA.name)
                        } else {
                            Text("Select country")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("To") {
                Button {
                    showPickerB = true
                } label: {
                    HStack {
                        if let countryB {
                            FlagView(countryCode: countryB.code, height: 30)
                            Text(countryB.name)
                        } else {
                            Text("Select country")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if let pair = selectedPair {
                Section("Comparison") {
                    HStack {
                        Text(pair.0.name)
                            .font(DesignSystem.Font.system(size: 22, weight: .semibold))
                        Image(systemName: "arrow.left.arrow.right")
                            .foregroundStyle(DesignSystem.Color.accent)
                        Text(pair.1.name)
                            .font(DesignSystem.Font.system(size: 22, weight: .semibold))
                    }

                    HStack {
                        Text("Same continent?")
                        Spacer()
                        Text(pair.0.continent == pair.1.continent ? "Yes" : "No")
                            .foregroundStyle(
                                pair.0.continent == pair.1.continent
                                    ? DesignSystem.Color.success
                                    : DesignSystem.Color.textSecondary
                            )
                    }
                }
            }
        }
        .navigationTitle("Distance Calculator")
        .sheet(isPresented: $showPickerA) {
            CountryPickerSheet(countries: countryDataService.countries) { countryA = $0 }
        }
        .sheet(isPresented: $showPickerB) {
            CountryPickerSheet(countries: countryDataService.countries) { countryB = $0 }
        }
    }
}

// MARK: - Currency Info
struct CurrencyInfoScreen: View {
    let countryDataService: CountryDataService

    var body: some View {
        List(countryDataService.countries.sorted { $0.currency.code < $1.currency.code }) { country in
            HStack(spacing: DesignSystem.Spacing.lg) {
                FlagView(countryCode: country.code, height: 32)

                Text(country.name)
                    .font(DesignSystem.Font.system(size: 20))

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(country.currency.code)
                        .font(DesignSystem.Font.system(size: 20, weight: .semibold))
                        .foregroundStyle(DesignSystem.Color.accent)

                    Text(country.currency.name)
                        .font(DesignSystem.Font.system(size: 22))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Currencies")
    }
}

// MARK: - Time Zones
struct TimeZoneScreen: View {
    let countryDataService: CountryDataService

    var body: some View {
        List(countryDataService.countries.sorted { $0.name < $1.name }) { country in
            HStack(spacing: DesignSystem.Spacing.lg) {
                FlagView(countryCode: country.code, height: 32)

                Text(country.name)
                    .font(DesignSystem.Font.system(size: 20))

                Spacer()

                Text(country.capital)
                    .font(DesignSystem.Font.system(size: 22))
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Time Zones")
    }
}
