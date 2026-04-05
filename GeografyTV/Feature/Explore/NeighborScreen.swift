import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import Geografy_Feature_NeighborExplorer
import SwiftUI

struct NeighborScreen: View {
    let countryDataService: CountryDataService

    @State private var selectedCountry: Country?

    var body: some View {
        List {
            if let country = selectedCountry {
                selectedCountrySection(country)
            }

            Section("Choose a Country") {
                ForEach(countryDataService.countries.sorted(by: \.name)) { country in
                    Button {
                        selectedCountry = country
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            FlagView(countryCode: country.code, height: 32)

                            Text(country.name)
                                .font(DesignSystem.Font.system(size: 20))

                            Spacer()

                            let count = CountryNeighbors.data[country.code]?.count ?? 0
                            if count > 0 {
                                Text("\(count) neighbors")
                                    .font(DesignSystem.Font.system(size: 22))
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Island")
                                    .font(DesignSystem.Font.system(size: 22))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Neighbor Explorer")
    }
}

// MARK: - Selected Country
private extension NeighborScreen {
    func selectedCountrySection(_ country: Country) -> some View {
        let neighborCodes = CountryNeighbors.data[country.code] ?? []
        let neighbors = neighborCodes.compactMap { code in
            countryDataService.countries.first { $0.code == code }
        }
        .sorted(by: \.name)

        return Section("\(country.name) \u{2014} \(neighbors.count) neighbors") {
            if neighbors.isEmpty {
                Text("\(country.name) is an island nation with no land borders")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(neighbors) { neighbor in
                    Button {
                        selectedCountry = neighbor
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            FlagView(countryCode: neighbor.code, height: 36)

                            Text(neighbor.name)
                                .font(DesignSystem.Font.system(size: 22, weight: .semibold))

                            Spacer()

                            Text(neighbor.capital)
                                .font(DesignSystem.Font.system(size: 22))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
