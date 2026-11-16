import Foundation

/// Formats a moment as the clock and calendar show it in a zone, keeping one formatter per zone.
///
/// The clock lists draw a row per country; building formatters inside each row cost several per row per update.
@MainActor
enum ZoneClockFormatter {
    // MARK: - Properties
    private static var timeFormatters: [String: DateFormatter] = [:]
    private static var dayFormatters: [String: DateFormatter] = [:]

    // MARK: - Formatting
    /// The short time, such as "9:41 AM".
    static func time(_ date: Date, in zone: TimeZone) -> String {
        let formatter = cachedFormatter(in: zone, cache: &timeFormatters) { formatter in
            formatter.timeStyle = .short
            formatter.dateStyle = .none
        }
        return formatter.string(from: date)
    }

    /// The weekday and date, such as "Sat, Nov 14".
    static func day(_ date: Date, in zone: TimeZone) -> String {
        let formatter = cachedFormatter(in: zone, cache: &dayFormatters) { formatter in
            formatter.dateFormat = "EEE, MMM d"
        }
        return formatter.string(from: date)
    }
}

// MARK: - Helpers
private extension ZoneClockFormatter {
    static func cachedFormatter(
        in zone: TimeZone,
        cache: inout [String: DateFormatter],
        configure: (DateFormatter) -> Void
    ) -> DateFormatter {
        if let formatter = cache[zone.identifier] {
            return formatter
        }
        let formatter = DateFormatter()
        formatter.timeZone = zone
        configure(formatter)
        cache[zone.identifier] = formatter
        return formatter
    }
}
