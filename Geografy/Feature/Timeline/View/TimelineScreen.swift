import SwiftUI

struct TimelineScreen: View {
    @Environment(TabCoordinator.self) private var coordinator

    @State private var countryDataService = CountryDataService()

    @State private var timelineService = TimelineService()
    @State private var selectedYear = 1960
    @State private var filter = TimelineFilter()
    @State private var selectedEvent: HistoricalEvent?
    @State private var showTodaySection = true
    @State private var showHistoricalMap = false

    var body: some View {
        VStack(spacing: 0) {
            filterBar
            eventList
            timelineSliderSection
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            countryDataService.loadCountries()
            timelineService.loadEvents()
        }
        .toolbar { historicalMapToolbarItem }
        .fullScreenCover(isPresented: $showHistoricalMap) {
            HistoricalMapScreen(initialYear: selectedYear)
        }
        .sheet(item: $selectedEvent) { event in
            eventDetailSheet(for: event)
        }
    }
}

// MARK: - Subviews

private extension TimelineScreen {
    var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                continentMenu
                eventTypeMenu
                if filter.isActive {
                    clearFilterButton
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .readableContentWidth()
        }
    }

    var continentMenu: some View {
        Menu {
            Button {
                filter.continent = nil
            } label: {
                Label(
                    "All Continents",
                    systemImage: filter.continent == nil
                        ? "checkmark" : "globe"
                )
            }
            ForEach(selectableContinents, id: \.self) { continent in
                Button {
                    filter.continent = continent
                } label: {
                    Label(
                        continent.displayName,
                        systemImage: filter.continent == continent
                            ? "checkmark" : "globe"
                    )
                }
            }
        } label: {
            filterChip(
                title: filter.continent?.displayName ?? "Continent",
                icon: "globe",
                isActive: filter.continent != nil
            )
        }
    }

    var eventTypeMenu: some View {
        Menu {
            Button {
                filter.eventType = nil
            } label: {
                Label(
                    "All Types",
                    systemImage: filter.eventType == nil
                        ? "checkmark" : "list.bullet"
                )
            }
            ForEach(HistoricalEvent.EventType.allCases, id: \.self) { type in
                Button {
                    filter.eventType = type
                } label: {
                    Label(
                        type.displayName,
                        systemImage: filter.eventType == type
                            ? "checkmark" : type.icon
                    )
                }
            }
        } label: {
            filterChip(
                title: filter.eventType?.displayName ?? "Event Type",
                icon: "line.3.horizontal.decrease",
                isActive: filter.eventType != nil
            )
        }
    }

    var clearFilterButton: some View {
        Button {
            withAnimation { filter = TimelineFilter() }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    func filterChip(title: String, icon: String, isActive: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
            Text(title)
                .font(DesignSystem.Font.caption)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            isActive
                ? DesignSystem.Color.accent.opacity(0.2)
                : DesignSystem.Color.cardBackground
        )
        .foregroundStyle(
            isActive
                ? DesignSystem.Color.accent
                : DesignSystem.Color.textSecondary
        )
        .clipShape(Capsule())
    }

    var eventList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                if showTodaySection {
                    TimelineTodaySection(
                        events: todayEvents,
                        countries: countryDataService.countries
                    )
                    .padding(.bottom, DesignSystem.Spacing.sm)
                }

                eventsForSelectedYear
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .animation(.easeInOut, value: selectedYear)
    }

    @ViewBuilder
    var eventsForSelectedYear: some View {
        let yearEvents = filteredEventsForYear
        if yearEvents.isEmpty {
            emptyStateView
        } else {
            SectionHeaderView(title: "\(String(selectedYear)) Events")
            ForEach(yearEvents) { event in
                Button {
                    selectedEvent = event
                } label: {
                    TimelineEventCard(
                        event: event,
                        country: countryDataService.country(for: event.countryCode)
                    )
                }
                .buttonStyle(PressButtonStyle())
            }
        }
    }

    var emptyStateView: some View {
        EmptyStateView(
            icon: "clock.arrow.trianglehead.counterclockwise.rotate.90",
            title: "No events in \(String(selectedYear))",
            subtitle: "Try adjusting filters or selecting a different year"
        )
    }

    var timelineSliderSection: some View {
        CardView {
            TimelineSlider(
                selectedYear: $selectedYear,
                range: 1800...2025,
                decades: timelineService.decades(in: 1800...2025),
                eventCountForDecade: { decade in
                    timelineService.eventCount(
                        forDecade: decade,
                        filter: filter,
                        countries: countryDataService.countries
                    )
                }
            )
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.bottom, DesignSystem.Spacing.xs)
    }

    func eventDetailSheet(for event: HistoricalEvent) -> some View {
        NavigationStack {
            eventDetailContent(for: event)
                .navigationTitle("Event Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        CircleCloseButton {
                            selectedEvent = nil
                        }
                    }
                }
        }
    }

    func eventDetailContent(for event: HistoricalEvent) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                detailHeader(for: event)
                detailDescription(for: event)
                if let country = countryDataService.country(
                    for: event.countryCode
                ) {
                    detailCountryInfo(country: country)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background)
    }

    func detailHeader(for event: HistoricalEvent) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(
                    countryCode: event.countryCode,
                    height: DesignSystem.Size.xxl
                )
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(event.title)
                        .font(DesignSystem.Font.title2)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(event.formattedDate)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
            }
            detailEventTypePill(for: event)
        }
    }

    func detailEventTypePill(for event: HistoricalEvent) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: event.type.icon)
            Text(event.type.displayName)
        }
        .font(DesignSystem.Font.caption)
        .foregroundStyle(DesignSystem.Color.onAccent)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(DesignSystem.Color.accent)
        .clipShape(Capsule())
    }

    func detailDescription(for event: HistoricalEvent) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            SectionHeaderView(title: "About")
            Text(event.description)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    func detailCountryInfo(country: Country) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            SectionHeaderView(title: "Country", icon: "globe")
            Button { coordinator.push(.countryDetail(country)) } label: {
                CountryRowView(
                    country: country,
                    isFavorite: false,
                    showContinent: true
                )
            }
            .buttonStyle(PressButtonStyle())
        }
    }
}

// MARK: - Toolbar

private extension TimelineScreen {
    @ToolbarContentBuilder
    var historicalMapToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button { showHistoricalMap = true } label: {
                Label("Historical Map", systemImage: "map.fill")
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Computed Properties

private extension TimelineScreen {
    var selectableContinents: [Country.Continent] {
        Country.Continent.allCases.filter { $0 != .antarctica }
    }

    var filteredEventsForYear: [HistoricalEvent] {
        timelineService.events(
            for: selectedYear,
            filter: filter,
            countries: countryDataService.countries
        )
    }

    var todayEvents: [HistoricalEvent] {
        timelineService.todayEvents(countries: countryDataService.countries)
    }
}
