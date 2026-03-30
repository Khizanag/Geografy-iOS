#if !os(tvOS)
import Foundation
import Observation
import WidgetKit

@Observable
@MainActor
final class WidgetDataBridge {
    private static let defaults = UserDefaults(suiteName: "group.com.khizanag.geografy.dev")

    private var countryDataService = CountryDataService()

    func synchronize(
        streak: Int,
        totalXP: Int,
        level: UserLevel,
        progressFraction: Double,
        visitedCount: Int
    ) {
        guard let defaults = Self.defaults else { return }

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

        guard let country = countryDataService.countryOfTheDay() else { return }

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
