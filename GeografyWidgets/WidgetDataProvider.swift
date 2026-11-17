import Foundation

enum WidgetDataProvider {
    static var countryOfDay: WidgetContract.CountryOfDay? {
        guard let data = defaults?.data(forKey: WidgetContract.Key.countryOfDay) else { return nil }
        return try? JSONDecoder().decode(WidgetContract.CountryOfDay.self, from: data)
    }

    static var streak: Int {
        defaults?.integer(forKey: WidgetContract.Key.streak) ?? 0
    }

    static var totalXP: Int {
        defaults?.integer(forKey: WidgetContract.Key.totalXP) ?? 0
    }

    static var levelNumber: Int {
        max(defaults?.integer(forKey: WidgetContract.Key.level) ?? 1, 1)
    }

    static var levelTitle: String {
        defaults?.string(forKey: WidgetContract.Key.levelTitle) ?? "Explorer"
    }

    static var progressFraction: Double {
        defaults?.double(forKey: WidgetContract.Key.progressFraction) ?? 0
    }

    static var visitedCount: Int {
        defaults?.integer(forKey: WidgetContract.Key.visitedCount) ?? 0
    }

    static var totalCountries: Int {
        defaults?.integer(forKey: WidgetContract.Key.totalCountries) ?? 197
    }

    private static var defaults: UserDefaults? { WidgetContract.defaults }
}
