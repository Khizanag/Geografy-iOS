import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct TimelineTodaySection: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryDataService

    public let events: [HistoricalEvent]

    // MARK: - Body
    public var body: some View {
        if !events.isEmpty {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                SectionHeaderView(title: "This Day in History", icon: "calendar")
                todayDateLabel
                eventCards
            }
        }
    }
}

// MARK: - Subviews
private extension TimelineTodaySection {
    var todayDateLabel: some View {
        Text(formattedToday)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.textTertiary)
    }

    var eventCards: some View {
        ForEach(events) { event in
            TimelineEventCard(
                event: event,
                country: countryDataService.country(for: event.countryCode)
            )
        }
    }
}

// MARK: - Helpers
private extension TimelineTodaySection {
    static let todayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }()

    var formattedToday: String {
        Self.todayFormatter.string(from: Date())
    }
}
