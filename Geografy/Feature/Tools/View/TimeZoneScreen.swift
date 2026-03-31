import SwiftUI

struct TimeZoneScreen: View {
    @Environment(Coordinator.self) private var coordinator: Coordinator?
    @Environment(HapticsService.self) private var hapticsService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var countryDataService = CountryDataService()

    @State private var selectedTab: TimeZoneTab = .worldClock
    @State private var blobAnimating = false

    var body: some View {
        VStack(spacing: 0) {
            tabPicker
            tabContent
        }
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Time Zones")
        .navigationBarTitleDisplayMode(.inline)
        .task { countryDataService.loadCountries() }
        .onAppear {
            guard !reduceMotion else { blobAnimating = true; return }
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                blobAnimating = true
            }
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
            AllZonesView(countries: countriesWithZones)
        }
    }

    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.indigo.opacity(0.20), .clear],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 400, height: 300)
                .blur(radius: 36)
                .offset(x: -80, y: -60)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.purple.opacity(0.14), .clear],
                        center: .center, startRadius: 0, endRadius: 180
                    )
                )
                .frame(width: 360, height: 280)
                .blur(radius: 40)
                .offset(x: 140, y: 400)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Helpers
private extension TimeZoneScreen {
    var countriesWithZones: [CountryWithZone] {
        countryDataService.countries.compactMap { country in
            guard let zone = CountryTimeZoneData.timeZone(for: country.code) else { return nil }
            return CountryWithZone(country: country, timeZone: zone)
        }
        .sorted { $0.country.name < $1.country.name }
    }
}

// MARK: - CountryWithZone
struct CountryWithZone: Identifiable {
    let country: Country
    let timeZone: TimeZone

    var id: String { country.code }

    var currentTime: Date { Date() }

    var utcOffsetHours: Double {
        Double(timeZone.secondsFromGMT(for: Date())) / 3600
    }

    var utcOffsetLabel: String {
        let hours = utcOffsetHours
        let sign = hours >= 0 ? "+" : ""
        if hours == Double(Int(hours)) {
            return "UTC\(sign)\(Int(hours))"
        }
        let absHours = abs(hours)
        let wholeHours = Int(absHours)
        let minutes = Int((absHours - Double(wholeHours)) * 60)
        return "UTC\(sign)\(wholeHours):\(String(format: "%02d", minutes))"
    }
}

// MARK: - World Clock View
private struct WorldClockView: View {
    @Environment(Coordinator.self) private var coordinator: Coordinator?

    let countries: [CountryWithZone]
    @State private var searchText = ""
    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        List(filteredCountries) { item in
            Button { coordinator?.push(.countryDetail(item.country)) } label: {
                worldClockRow(for: item)
            }
            .listRowBackground(DesignSystem.Color.cardBackground)
            .listRowSeparatorTint(DesignSystem.Color.textTertiary.opacity(0.2))
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search country…")
        .onReceive(timer) { date in now = date }
    }

    private var filteredCountries: [CountryWithZone] {
        guard !searchText.isEmpty else { return countries }
        let query = searchText.lowercased()
        return countries.filter { $0.country.name.lowercased().contains(query) }
    }

    private func worldClockRow(for item: CountryWithZone) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: item.country.code, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.country.name)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)
                Text(item.utcOffsetLabel)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(currentTimeString(for: item.timeZone))
                    .font(DesignSystem.Font.monoSmall)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.default, value: now)
                Text(currentDateString(for: item.timeZone))
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.country.name), \(item.utcOffsetLabel), \(currentTimeString(for: item.timeZone))")
    }

    private func currentTimeString(for zone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.timeZone = zone
        return formatter.string(from: now)
    }

    private func currentDateString(for zone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        formatter.timeZone = zone
        return formatter.string(from: now)
    }
}

// MARK: - All Zones View
private struct AllZonesView: View {
    @Environment(Coordinator.self) private var coordinator: Coordinator?

    let countries: [CountryWithZone]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                ForEach(groupedZones, id: \.offset) { group in
                    zoneGroup(offset: group.offset, countries: group.countries)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    private struct ZoneGroup {
        let offset: Double
        let countries: [CountryWithZone]
    }

    private var groupedZones: [ZoneGroup] {
        var dict: [Double: [CountryWithZone]] = [:]
        for item in countries {
            let offset = item.utcOffsetHours
            dict[offset, default: []].append(item)
        }
        return dict.map { ZoneGroup(offset: $0.key, countries: $0.value.sorted { $0.country.name < $1.country.name }) }
            .sorted { $0.offset < $1.offset }
    }

    private func zoneGroup(offset: Double, countries: [CountryWithZone]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            offsetHeader(offset: offset)
            CardView {
                VStack(spacing: 0) {
                    ForEach(Array(countries.enumerated()), id: \.element.id) { index, item in
                        if index > 0 {
                            Divider()
                                .padding(.leading, 44)
                        }
                        Button { coordinator?.push(.countryDetail(item.country)) } label: {
                            zoneCountryRow(for: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func offsetHeader(offset: Double) -> some View {
        let sign = offset >= 0 ? "+" : ""
        let label: String
        if offset == Double(Int(offset)) {
            label = "UTC\(sign)\(Int(offset))"
        } else {
            let absHours = abs(offset)
            let wholeHours = Int(absHours)
            let minutes = Int((absHours - Double(wholeHours)) * 60)
            label = "UTC\(sign)\(wholeHours):\(String(format: "%02d", minutes))"
        }

        return HStack(spacing: DesignSystem.Spacing.xs) {
            RoundedRectangle(cornerRadius: 2)
                .fill(zoneColor(for: offset))
                .frame(width: 3, height: 18)
                .accessibilityHidden(true)
            Text(label)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .accessibilityAddTraits(.isHeader)
    }

    private func zoneCountryRow(for item: CountryWithZone) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: item.country.code, height: 20)
                .frame(width: 32, alignment: .center)
            Text(item.country.name)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
            Spacer()
            Text(currentTimeString(for: item.timeZone))
                .font(DesignSystem.Font.monoCaption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .accessibilityElement(children: .combine)
    }

    private func currentTimeString(for zone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = zone
        return formatter.string(from: Date())
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
