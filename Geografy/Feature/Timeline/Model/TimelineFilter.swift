import Foundation

struct TimelineFilter: Equatable {
    var continent: Country.Continent?
    var eventType: HistoricalEvent.EventType?
    var yearRange: ClosedRange<Int> = 1800...2025

    var isActive: Bool {
        continent != nil || eventType != nil
    }
}
