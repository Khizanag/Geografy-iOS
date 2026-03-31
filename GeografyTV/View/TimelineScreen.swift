import SwiftUI
import GeografyDesign

struct TimelineScreen: View {
    @State private var service = TimelineService()
    @State private var selectedType: HistoricalEvent.EventType?

    private var displayedEvents: [HistoricalEvent] {
        guard let selectedType else {
            return service.events.sorted { $0.year > $1.year }
        }
        return service.events
            .filter { $0.type == selectedType }
            .sorted { $0.year > $1.year }
    }

    var body: some View {
        List {
            Section {
                Picker("Event Type", selection: $selectedType) {
                    Text("All").tag(nil as HistoricalEvent.EventType?)
                    ForEach(HistoricalEvent.EventType.allCases, id: \.self) { type in
                        Label(type.displayName, systemImage: type.icon)
                            .tag(type as HistoricalEvent.EventType?)
                    }
                }
            }

            let todayEvents = service.events.filter(\.matchesToday)
            if !todayEvents.isEmpty {
                Section("On This Day") {
                    ForEach(todayEvents) { event in
                        eventRow(event)
                    }
                }
            }

            Section("Events (\(displayedEvents.count))") {
                ForEach(displayedEvents) { event in
                    eventRow(event)
                }
            }
        }
        .navigationTitle("Timeline")
        .task { service.loadEvents() }
    }
}

// MARK: - Subviews
private extension TimelineScreen {
    func eventRow(_ event: HistoricalEvent) -> some View {
        HStack(spacing: 20) {
            Text(event.formattedDate)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: 160, alignment: .leading)

            FlagView(countryCode: event.countryCode, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 20, weight: .semibold))

                Text(event.description)
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: event.type.icon)
                .font(.system(size: 20))
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }
}
