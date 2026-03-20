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
            let decoded = try JSONDecoder().decode([Country].self, from: data)
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
