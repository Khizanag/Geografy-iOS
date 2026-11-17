import Foundation

/// What the app writes for its widgets and the widgets read. Both targets compile this one file, so the app
/// group, the keys, and the country model can't drift apart.
enum WidgetContract {
    static let appGroup = "group.com.khizanag.geografy.dev"

    /// The shared defaults, nil when the app group isn't set up for this build.
    static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroup)
    }

    enum Key {
        static let streak = "widget_streak"
        static let totalXP = "widget_xp"
        static let level = "widget_level"
        static let levelTitle = "widget_level_title"
        static let progressFraction = "widget_progress_fraction"
        static let visitedCount = "widget_visited_count"
        static let totalCountries = "widget_total_countries"
        static let countryOfDay = "widget_country_of_day"
        /// The day `countryOfDay` was written for, as yyyy-MM-dd.
        static let countryOfDayDate = "widget_country_of_day_date"
    }

    /// The links that open the app at a place: `geografy://country/{code}` and `geografy://daily`, plus the
    /// tab links older widgets used.
    enum Link {
        static let scheme = "geografy"
        static let countryHost = "country"
        static let dailyHost = "daily"

        static func country(_ code: String) -> URL? {
            URL(string: "\(scheme)://\(countryHost)/\(code)")
        }

        static let daily = URL(string: "\(scheme)://\(dailyHost)")
    }

    /// The country of the day as the widget shows it.
    struct CountryOfDay: Codable {
        let code: String
        let name: String
        let capital: String
        let continent: String
        let flagEmoji: String
        let funFact: String
    }
}
