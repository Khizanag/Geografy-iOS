#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct TimeZoneScreen: View {
    // MARK: - Init
    public init() {}
    #if !os(tvOS)
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator: Navigator?
    #endif
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedTab: TimeZoneTab = .worldClock
    @State private var countriesWithZones: [CountryWithZone] = []
    @State private var zoneGroups: [TimeZoneGroup] = []

    // MARK: - Body
    public var body: some View {
        mainContent
            .screenBackground()
            .navigationTitle("Time Zones")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: countryDataService.countries.count, initial: true) {
                buildZones()
            }
    }
}

// MARK: - Tab Enum
private extension TimeZoneScreen {
    enum TimeZoneTab: CaseIterable {
        case worldClock
        case allZones

        var label: String {
            switch self {
            case .worldClock: "World Clock"
            case .allZones: "By Zone"
            }
        }

        var icon: String {
            switch self {
            case .worldClock: "clock.fill"
            case .allZones: "list.bullet.rectangle"
            }
        }
    }
}

// MARK: - Subviews
private extension TimeZoneScreen {
    var mainContent: some View {
        VStack(spacing: 0) {
            tabPicker
            tabContent
        }
    }

    var tabPicker: some View {
        Picker("", selection: $selectedTab) {
            ForEach(TimeZoneTab.allCases, id: \.label) { tab in
                Label(tab.label, systemImage: tab.icon)
                    .tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    @ViewBuilder
    var tabContent: some View {
        switch selectedTab {
        case .worldClock:
            WorldClockView(countries: countriesWithZones)
        case .allZones:
            AllZonesView(groups: zoneGroups)
        }
    }
}

// MARK: - Actions
private extension TimeZoneScreen {
    /// Each country's zone is looked up and sorted once, not on every render of either tab.
    func buildZones() {
        countriesWithZones = countryDataService.countries
            .compactMap { country in
                guard let zone = CountryTimeZoneData.timeZone(for: country.code) else { return nil }
                return CountryWithZone(country: country, timeZone: zone)
            }
            .sorted { $0.country.name < $1.country.name }
        zoneGroups = TimeZoneGroup.groups(from: countriesWithZones)
    }
}

// MARK: - World Clock View
private struct WorldClockView: View {
    #if !os(tvOS)
    @Environment(Navigator.self) private var coordinator: Navigator?
    #endif

    let countries: [CountryWithZone]
    @State private var searchText = ""

    var body: some View {
        listContent
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Search country…")
    }

    private var listContent: some View {
        List(filteredCountries) { item in
            Button {
                #if !os(tvOS)
                coordinator?.push(CountryRoute.countryDetail(item.country))
                #endif
            } label: {
                TimelineView(.everyMinute) { context in
                    worldClockRow(for: item, at: context.date)
                }
            }
            .listRowBackground(DesignSystem.Color.cardBackground)
            .listRowSeparatorTint(DesignSystem.Color.textTertiary.opacity(0.2))
        }
    }

    private var filteredCountries: [CountryWithZone] {
        guard !searchText.isEmpty else { return countries }
        let query = searchText.lowercased()
        return countries.filter { $0.country.name.lowercased().contains(query) }
    }

    private func worldClockRow(for item: CountryWithZone, at date: Date) -> some View {
        let offsetLabel = item.utcOffsetLabel
        let time = ZoneClockFormatter.time(date, in: item.timeZone)
        return CountryListRow(country: item.country, subtitle: offsetLabel) {
            VStack(alignment: .trailing, spacing: 2) {
                Text(time)
                    .font(DesignSystem.Font.monoSmall)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.default, value: time)
                Text(ZoneClockFormatter.day(date, in: item.timeZone))
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.country.name), \(offsetLabel), \(time)")
    }
}

// MARK: - All Zones View
private struct AllZonesView: View {
    #if !os(tvOS)
    @Environment(Navigator.self) private var coordinator: Navigator?
    #endif

    let groups: [TimeZoneGroup]

    var body: some View {
        scrollContent
    }

    private var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                ForEach(groups, id: \.offset) { group in
                    zoneGroup(offset: group.offset, countries: group.countries)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    private func zoneGroup(offset: Double, countries: [CountryWithZone]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            offsetHeader(offset: offset)
            CardView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(countries.enumerated()), id: \.element.id) { index, item in
                        if index > 0 {
                            Divider()
                                .padding(.leading, 44)
                        }
                        Button {
                            #if !os(tvOS)
                            coordinator?.push(CountryRoute.countryDetail(item.country))
                            #endif
                        } label: {
                            zoneCountryRow(for: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func offsetHeader(offset: Double) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(zoneColor(for: offset))
                .frame(width: 3, height: 18)
                .accessibilityHidden(true)
            Text(CountryWithZone.utcOffsetLabel(forHours: offset))
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .accessibilityAddTraits(.isHeader)
    }

    private func zoneCountryRow(for item: CountryWithZone) -> some View {
        CountryListRow(country: item.country) {
            Text(ZoneClockFormatter.time(Date(), in: item.timeZone))
                .font(DesignSystem.Font.monoCaption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .accessibilityElement(children: .combine)
    }

    private func zoneColor(for offset: Double) -> Color {
        let colors: [Color] = [
            DesignSystem.Color.blue,
            DesignSystem.Color.indigo,
            DesignSystem.Color.purple,
            DesignSystem.Color.accent,
            DesignSystem.Color.success,
            DesignSystem.Color.warning,
            DesignSystem.Color.orange,
        ]
        let normalized = (offset + 12) / 26
        let index = Int(normalized * Double(colors.count - 1))
        return colors[max(0, min(index, colors.count - 1))]
    }
}
#endif
