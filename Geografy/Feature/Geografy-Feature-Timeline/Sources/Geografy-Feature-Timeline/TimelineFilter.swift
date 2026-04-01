import Foundation
import Geografy_Core_Common

public struct TimelineFilter: Equatable {
    public var continent: Country.Continent?
    public var eventType: HistoricalEvent.EventType?
    public var yearRange: ClosedRange<Int> = 1800...2025

    public var isActive: Bool {
        continent != nil || eventType != nil
    }
}
