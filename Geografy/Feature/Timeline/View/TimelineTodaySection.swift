import SwiftUI

struct TimelineTodaySection: View {
    let events: [HistoricalEvent]
    let countries: [Country]

    var body: some View {
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
                country: country(for: event.countryCode)
            )
        }
    }
}

// MARK: - Helpers
private extension TimelineTodaySection {
    var formattedToday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: Date())
    }

    func country(for code: String) -> Country? {
        countries.first { $0.code == code }
    }
}
