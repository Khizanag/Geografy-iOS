import Foundation

struct HistoricalEvent: Identifiable, Codable {
    var id: String { "\(countryCode)-\(year)-\(type.rawValue)" }

    let year: Int
    let month: Int?
    let day: Int?
    let countryCode: String
    let type: EventType
    let title: String
    let description: String

    enum EventType: String, Codable, CaseIterable {
        case independence
        case nameChange
        case borderChange
        case formation
        case dissolution
    }
}

// MARK: - Display Helpers

extension HistoricalEvent {
    var dateComponents: DateComponents {
        DateComponents(year: year, month: month, day: day)
    }

    var formattedDate: String {
        if let month, let day {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            if let date = Calendar.current.date(from: components) {
                return dateFormatter.string(from: date)
            }
        }
        if let month {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            var components = DateComponents()
            components.year = year
            components.month = month
            if let date = Calendar.current.date(from: components) {
                return dateFormatter.string(from: date)
            }
        }
        return String(year)
    }

    var matchesToday: Bool {
        let today = Calendar.current.dateComponents([.month, .day], from: Date())
        guard let eventMonth = month, let eventDay = day else { return false }
        return eventMonth == today.month && eventDay == today.day
    }
}

// MARK: - Event Type Display

extension HistoricalEvent.EventType {
    var displayName: String {
        switch self {
        case .independence: "Independence"
        case .nameChange: "Name Change"
        case .borderChange: "Border Change"
        case .formation: "Formation"
        case .dissolution: "Dissolution"
        }
    }

    var icon: String {
        switch self {
        case .independence: "flag.fill"
        case .nameChange: "textformat"
        case .borderChange: "map.fill"
        case .formation: "plus.circle.fill"
        case .dissolution: "xmark.circle.fill"
        }
    }
}
