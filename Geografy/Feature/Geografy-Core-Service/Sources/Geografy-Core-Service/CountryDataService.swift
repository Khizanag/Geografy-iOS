import Foundation
import GeografyCore

@Observable
@MainActor
public final class CountryDataService {
    public private(set) var countries: [Country] = []
    private var countriesByCode: [String: Country] = [:]

    public init() {}

    public func loadCountries() {
        guard countries.isEmpty else { return }
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return
        }

        do {
            var decoded = try JSONDecoder().decode([Country].self, from: data)
            applySupplementaryCapitals(&decoded)
            countries = decoded
            countriesByCode = Dictionary(uniqueKeysWithValues: decoded.map { ($0.code, $0) })
        } catch {
            print("Failed to decode countries: \(error)")
        }
    }

    public func country(for code: String) -> Country? {
        countriesByCode[code]
    }

    public func countryOfTheDay(for date: Date = .now) -> Country? {
        guard !countries.isEmpty else { return nil }
        let sorted = countries.sorted { $0.code < $1.code }
        let year = Calendar.current.component(.year, from: date)
        let dayOfYear = (Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1) - 1
        let shuffled = sorted.seededShuffle(seed: UInt64(year) &* 2_654_435_761)
        return shuffled[dayOfYear % shuffled.count]
    }
}

// MARK: - Helpers
private extension CountryDataService {
    func applySupplementaryCapitals(_ countries: inout [Country]) {
        for index in countries.indices where countries[index].capitals == nil {
            if let supplementary = MultipleCapitalsData.data[countries[index].code] {
                countries[index].capitals = supplementary
            }
        }
    }
}
