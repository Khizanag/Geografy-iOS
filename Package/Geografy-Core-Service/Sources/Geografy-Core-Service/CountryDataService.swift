import Foundation
import Geografy_Core_Common

@Observable
@MainActor
public final class CountryDataService {
    public private(set) var countries: [Country] = []
    private var countriesByCode: [String: Country] = [:]

    public init() {}

    public func loadCountries() async {
        guard countries.isEmpty else { return }
        guard let result = await Self.parseCountriesFile() else { return }
        countries = result.countries
        countriesByCode = result.byCode
    }

    nonisolated private static func parseCountriesFile() async -> (countries: [Country], byCode: [String: Country])? {
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        do {
            var decoded = try JSONDecoder().decode([Country].self, from: data)
            applySupplementaryCapitals(&decoded)
            let byCode = Dictionary(uniqueKeysWithValues: decoded.map { ($0.code, $0) })
            return (decoded, byCode)
        } catch {
            print("Failed to decode countries: \(error)")
            return nil
        }
    }

    public func country(for code: String) -> Country? {
        countriesByCode[code]
    }

    public func countryOfTheDay(for date: Date = .now) -> Country? {
        guard !countries.isEmpty else { return nil }
        let sorted = countries.sorted(by: \.code)
        let year = Calendar.current.component(.year, from: date)
        let dayOfYear = (Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1) - 1
        let shuffled = sorted.seededShuffle(seed: UInt64(year) &* 2_654_435_761)
        return shuffled[dayOfYear % shuffled.count]
    }
}

// MARK: - Helpers
private extension CountryDataService {
    nonisolated static func applySupplementaryCapitals(_ countries: inout [Country]) {
        for index in countries.indices where countries[index].capitals == nil {
            if let supplementary = MultipleCapitalsData.data[countries[index].code] {
                countries[index].capitals = supplementary
            }
        }
    }
}
