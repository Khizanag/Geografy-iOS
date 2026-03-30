#if !os(tvOS)
import Foundation
import Observation
import WidgetKit

@Observable
@MainActor
final class WidgetDataBridge {
    static let appGroupID = "group.com.khizanag.geografy"

    private var countryDataService = CountryDataService()

    func synchronize(
        streak: Int,
        totalXP: Int,
        level: UserLevel,
        progressFraction: Double,
        visitedCount: Int
    ) {
        guard let defaults = UserDefaults(suiteName: Self.appGroupID) else { return }

        defaults.set(streak, forKey: "widget_streak")
        defaults.set(totalXP, forKey: "widget_xp")
        defaults.set(level.level, forKey: "widget_level")
        defaults.set(level.title, forKey: "widget_level_title")
        defaults.set(progressFraction, forKey: "widget_progress_fraction")
        defaults.set(visitedCount, forKey: "widget_visited_count")
        defaults.set(197, forKey: "widget_total_countries")

        writeCountryOfDayIfNeeded(to: defaults)

        WidgetCenter.shared.reloadAllTimelines()
    }

    func loadCountriesIfNeeded() {
        if countryDataService.countries.isEmpty {
            countryDataService.loadCountries()
        }
    }
}

// MARK: - Country of Day
private extension WidgetDataBridge {
    func writeCountryOfDayIfNeeded(to defaults: UserDefaults) {
        if countryDataService.countries.isEmpty {
            countryDataService.loadCountries()
        }

        guard !countryDataService.countries.isEmpty else { return }

        let todayKey = todayDateKey()
        if let existing = defaults.string(forKey: "widget_country_of_day_date"),
           existing == todayKey,
           defaults.data(forKey: "widget_country_of_day") != nil {
            return
        }

        let sorted = countryDataService.countries.sorted { $0.code < $1.code }
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 1
        let country = sorted[(dayIndex - 1) % sorted.count]

        let data = WidgetCountryData(
            code: country.code,
            name: country.name,
            capital: country.capital,
            continent: country.continent.displayName,
            flagEmoji: country.flagEmoji,
            funFact: funFact(for: country)
        )

        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: "widget_country_of_day")
            defaults.set(todayKey, forKey: "widget_country_of_day_date")
        }
    }

    func todayDateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: .now)
    }

    func funFact(for country: Country) -> String {
        let population = country.population.formatPopulation()
        let area = country.area.formatArea()
        return "Population \(population) · \(area)"
    }
}

// MARK: - Shared Data Model
struct WidgetCountryData: Codable {
    let code: String
    let name: String
    let capital: String
    let continent: String
    let flagEmoji: String
    let funFact: String
}
#endif
