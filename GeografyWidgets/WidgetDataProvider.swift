import Foundation

enum WidgetDataProvider {
    nonisolated(unsafe) private static let defaults = UserDefaults(suiteName: "group.com.khizanag.geografy.dev")

    static var countryOfDay: WidgetCountryEntry? {
        guard let data = defaults?.data(forKey: "widget_country_of_day"),
              let decoded = try? JSONDecoder().decode(WidgetCountryEntry.self, from: data) else {
            return nil
        }
        return decoded
    }

    static var streak: Int {
        defaults?.integer(forKey: "widget_streak") ?? 0
    }

    static var totalXP: Int {
        defaults?.integer(forKey: "widget_xp") ?? 0
    }

    static var levelNumber: Int {
        max(defaults?.integer(forKey: "widget_level") ?? 1, 1)
    }

    static var levelTitle: String {
        defaults?.string(forKey: "widget_level_title") ?? "Explorer"
    }

    static var progressFraction: Double {
        defaults?.double(forKey: "widget_progress_fraction") ?? 0
    }

    static var visitedCount: Int {
        defaults?.integer(forKey: "widget_visited_count") ?? 0
    }

    static var totalCountries: Int {
        defaults?.integer(forKey: "widget_total_countries") ?? 197
    }
}

// MARK: - Shared Data Models
struct WidgetCountryEntry: Codable {
    let code: String
    let name: String
    let capital: String
    let continent: String
    let flagEmoji: String
    let funFact: String
}
