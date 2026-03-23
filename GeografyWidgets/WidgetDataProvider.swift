import Foundation

enum WidgetDataProvider {
    private static let suiteName = "group.com.khizanag.geografy"

    static var countryOfDay: WidgetCountryEntry? {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: "widget_country_of_day"),
              let decoded = try? JSONDecoder().decode(WidgetCountryEntry.self, from: data) else {
            return nil
        }
        return decoded
    }

    static var streak: Int {
        UserDefaults(suiteName: suiteName)?.integer(forKey: "widget_streak") ?? 0
    }

    static var totalXP: Int {
        UserDefaults(suiteName: suiteName)?.integer(forKey: "widget_xp") ?? 0
    }

    static var levelNumber: Int {
        let level = UserDefaults(suiteName: suiteName)?.integer(forKey: "widget_level") ?? 1
        return max(level, 1)
    }

    static var levelTitle: String {
        UserDefaults(suiteName: suiteName)?.string(forKey: "widget_level_title") ?? "Explorer"
    }

    static var progressFraction: Double {
        UserDefaults(suiteName: suiteName)?.double(forKey: "widget_progress_fraction") ?? 0
    }

    static var visitedCount: Int {
        UserDefaults(suiteName: suiteName)?.integer(forKey: "widget_visited_count") ?? 0
    }

    static var totalCountries: Int {
        UserDefaults(suiteName: suiteName)?.integer(forKey: "widget_total_countries") ?? 197
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
