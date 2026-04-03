#if os(iOS)
import CoreSpotlight
import Geografy_Core_Common

public enum SpotlightIndexer {
    private static let indexedCountKey = "spotlightIndexedCount"

    public static func indexCountriesIfNeeded(_ countries: [Country]) {
        let previousCount = UserDefaults.standard.integer(forKey: indexedCountKey)
        guard previousCount != countries.count else { return }
        indexCountries(countries)
    }

    public static func indexCountries(_ countries: [Country]) {
        let items = countries.map { country in
            let attributes = CSSearchableItemAttributeSet(contentType: .content)
            attributes.title = country.name
            attributes.contentDescription = "\(country.continent.displayName) · Capital: \(country.capital)"
            attributes.keywords = [
                country.name,
                country.capital,
                country.continent.displayName,
                country.code,
            ]
            return CSSearchableItem(
                uniqueIdentifier: "country-\(country.code)",
                domainIdentifier: "com.khizanag.geografy.countries",
                attributeSet: attributes
            )
        }
        CSSearchableIndex.default().indexSearchableItems(items)
        UserDefaults.standard.set(countries.count, forKey: indexedCountKey)
    }

    public static func deleteAll() {
        CSSearchableIndex.default().deleteAllSearchableItems()
    }
}
#endif
