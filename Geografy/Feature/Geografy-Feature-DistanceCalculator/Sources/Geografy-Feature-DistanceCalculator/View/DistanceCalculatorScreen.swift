import Foundation
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct DistanceCalculatorScreen: View {
    // MARK: - Properties
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var originCountry: Country?
    @State private var destinationCountry: Country?
    @State private var pickingSide: PairSide?
    @State private var recentRoutes: [RoutePair] = []

    private static let recentLimit = 5
    private static let recentStorageKey = "distance_recent_routes"

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Distance Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadRecentRoutes)
            .onChange(of: currentRoute?.id) { routeDidChange() }
            .sheet(item: $pickingSide) { side in
                CoordinatedNavigationStack(showCloseButton: true) {
                    picker(for: side)
                }
            }
    }
}

// MARK: - Subviews
private extension DistanceCalculatorScreen {
    var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                routeHeader
                content
                if !resolvedRecentRoutes.isEmpty {
                    recentSection
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xs)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    var routeHeader: some View {
        PairSelector(
            left: originCountry.map(slotItem),
            right: destinationCountry.map(slotItem),
            roles: (left: "Origin", right: "Destination"),
            placeholder: "Choose a country",
            centerLabel: "TO",
            onPick: { pickingSide = $0 },
            onClear: { setCountry(nil, on: $0) },
            onSwap: swapCountries
        )
    }

    func slotItem(_ country: Country) -> PairSlotItem {
        PairSlotItem(
            flagCode: country.code,
            title: country.name,
            subtitle: country.capital.isEmpty ? nil : country.capital
        )
    }

    @ViewBuilder
    var content: some View {
        if let route = currentRoute {
            if let metrics = route.metrics {
                DistanceResultView(origin: route.origin, destination: route.destination, metrics: metrics)
            } else {
                Text("This route can't be measured: a capital's location is missing.")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        } else {
            DistanceStartView(
                originCountry: originCountry,
                destinationCountry: destinationCountry,
                countries: routableCountries,
                onChoose: { country, side in setCountry(country, on: side) },
                onChooseRoute: open,
                onShuffle: shuffle
            )
        }
    }

    var recentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(
                title: "Recent",
                action: SectionHeaderAction("Clear", accessibilityLabel: "Clear recent routes", perform: clearRecents)
            )
            RowListCard(
                resolvedRecentRoutes,
                dividerInset: RowListCardLayout.dividerInset(after: RowListCardLayout.flagPairWidth)
            ) { route in
                RouteRow(route: route) {
                    open(route)
                }
            }
        }
    }

    func picker(for side: PairSide) -> some View {
        let otherCode = country(on: side.other)?.code
        return CountryPicker(
            side == .left ? "Origin" : "Destination",
            countries: routableCountries.filter { $0.code != otherCode },
            selectedCode: country(on: side)?.code
        ) { selected in
            setCountry(selected, on: side)
        }
    }
}

// MARK: - Actions
private extension DistanceCalculatorScreen {
    func country(on side: PairSide) -> Country? {
        switch side {
        case .left: originCountry
        case .right: destinationCountry
        }
    }

    func setCountry(_ country: Country?, on side: PairSide) {
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) {
            switch side {
            case .left: originCountry = country
            case .right: destinationCountry = country
            }
        }
    }

    func open(_ route: CountryRoute) {
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) {
            originCountry = route.origin
            destinationCountry = route.destination
        }
    }

    func swapCountries() {
        #if !os(tvOS)
        hapticsService.impact(.light)
        #endif
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) {
            (originCountry, destinationCountry) = (destinationCountry, originCountry)
        }
    }

    /// Fills whichever slots are empty with random countries.
    func shuffle() {
        let pool = routableCountries
        let origin = originCountry ?? pool.filter { $0.code != destinationCountry?.code }.randomElement()
        let destination = destinationCountry ?? pool.filter { $0.code != origin?.code }.randomElement()
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) {
            originCountry = origin
            destinationCountry = destination
        }
    }

    func clearRecents() {
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) {
            recentRoutes = []
        }
        saveRecentRoutes()
    }

    func routeDidChange() {
        guard let route = currentRoute else { return }
        recentRoutes = RoutePair.recents(recentRoutes, adding: route.pair, limit: Self.recentLimit)
        saveRecentRoutes()
        announce(route)
    }

    func announce(_ route: CountryRoute) {
        guard let metrics = route.metrics else { return }
        let kilometers = DistanceFormat.number(metrics.distanceKm)
        let places = "\(route.origin.routePlaceName) to \(route.destination.routePlaceName)"
        AccessibilityNotification.Announcement("\(kilometers) kilometers from \(places)").post()
    }
}

// MARK: - Helpers
private extension DistanceCalculatorScreen {
    var currentRoute: CountryRoute? {
        guard let originCountry, let destinationCountry else { return nil }
        return CountryRoute(origin: originCountry, destination: destinationCountry)
    }

    /// Only countries whose capital is on record, so every pick can be measured.
    var routableCountries: [Country] {
        countryDataService.countries.filter { CapitalCoordinateService.coordinate(for: $0.code) != nil }
    }

    var resolvedRecentRoutes: [CountryRoute] {
        recentRoutes.compactMap { pair in
            guard let origin = countryDataService.country(for: pair.originCode),
                  let destination = countryDataService.country(for: pair.destinationCode) else { return nil }
            return CountryRoute(origin: origin, destination: destination)
        }
    }
}

// MARK: - Recents
private extension DistanceCalculatorScreen {
    func saveRecentRoutes() {
        guard let data = try? JSONEncoder().encode(recentRoutes) else { return }
        UserDefaults.standard.set(data, forKey: UserScope.key(Self.recentStorageKey))
    }

    func loadRecentRoutes() {
        guard let data = UserDefaults.standard.data(forKey: UserScope.key(Self.recentStorageKey)),
              let decoded = try? JSONDecoder().decode([RoutePair].self, from: data) else {
            return
        }
        recentRoutes = decoded
    }
}
