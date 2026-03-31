#if canImport(CoreSpotlight)
import CoreSpotlight
import GeografyCore

enum SpotlightIndexer {
    static func indexCountries(_ countries: [Country]) {
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
    }

    static func deleteAll() {
        CSSearchableIndex.default().deleteAllSearchableItems()
    }
}
#endif
