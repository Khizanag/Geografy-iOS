import Foundation

@Observable
final class CountryDataService {
    private(set) var countries: [Country] = []
    private var countriesByCode: [String: Country] = [:]

    func loadCountries() {
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

    func country(for code: String) -> Country? {
        countriesByCode[code]
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
