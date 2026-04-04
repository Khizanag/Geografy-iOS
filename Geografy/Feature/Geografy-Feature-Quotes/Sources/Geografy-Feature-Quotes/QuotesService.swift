import Foundation
import Observation

@Observable
@MainActor
public final class QuotesService {
    private let favoritesKey = "geo_quotes_favorites"

    public private(set) var quotes: [Quote] = []

    public init() {
        quotes = Self.loadQuotesFromJSON()
        loadFavorites()
    }

    public func toggleFavorite(id: String) {
        guard let index = quotes.firstIndex(where: { $0.id == id }) else { return }
        quotes[index].isFavorited.toggle()
        saveFavorites()
    }

    public func quotes(for category: QuoteCategory?) -> [Quote] {
        guard let category else { return quotes }
        return quotes.filter { $0.category == category }
    }

    public func quotesOfTheDay() -> [Quote] {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let shuffled = quotes.sorted { a, _ in a.id.hashValue ^ dayOfYear.hashValue > 0 }
        return Array(shuffled.prefix(3))
    }

    public func favoriteQuotes() -> [Quote] {
        quotes.filter { $0.isFavorited }
    }
}

// MARK: - Data Loading
private extension QuotesService {
    struct JSONQuote: Decodable {
        let id: String
        let text: String
        let author: String
        let countryCode: String?
        let category: String
    }

    static func loadQuotesFromJSON() -> [Quote] {
        guard let url = Bundle.module.url(forResource: "quotes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([JSONQuote].self, from: data)
        else { return [] }

        return entries.map { entry in
            Quote(
                id: entry.id,
                text: entry.text,
                author: entry.author,
                countryCode: entry.countryCode,
                category: QuoteCategory(rawValue: entry.category) ?? .wisdom
            )
        }
    }
}

// MARK: - Persistence
private extension QuotesService {
    func loadFavorites() {
        let favoriteIds = Set(UserDefaults.standard.stringArray(forKey: favoritesKey) ?? [])
        for index in quotes.indices {
            quotes[index].isFavorited = favoriteIds.contains(quotes[index].id)
        }
    }

    func saveFavorites() {
        let favoriteIds = quotes.filter(\.isFavorited).map(\.id)
        UserDefaults.standard.set(favoriteIds, forKey: favoritesKey)
    }
}
