import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Map
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

/// Every continent as a tile that opens its own map.
public struct ContinentsScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(GeoJSONCache.self) private var geoJSONCache
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @AppStorage(MapPreferences.projectionKey) private var projection = MapProjectionKind.mercator.rawValue
    @AppStorage(MapPreferences.paletteKey) private var palette = MapPalette.default.rawValue

    @State private var outlines: [Country.Continent: ContinentOutline] = [:]

    private static let continents: [Country.Continent] = [
        .europe, .asia, .africa, .northAmerica, .southAmerica, .oceania,
    ]

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Continents")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: "\(projection)-\(palette)-\(geoJSONCache.revision)") { await loadOutlines() }
    }
}

// MARK: - Content
private extension ContinentsScreen {
    var isWideLayout: Bool { horizontalSizeClass == .regular }

    var columns: [GridItem] {
        let count = isWideLayout ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: DesignSystem.Spacing.sm), count: count)
    }

    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            continentGrid
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.top, DesignSystem.Spacing.sm)
                .padding(.bottom, DesignSystem.Spacing.xxl)
                .readableContentWidth(DesignSystem.AdaptiveLayout.maxWideContentWidth)
        }
    }
}

// MARK: - Continents
private extension ContinentsScreen {
    var continentGrid: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
            ForEach(Self.continents, id: \.self) { continent in
                ContinentTile(
                    continent: continent,
                    outline: outlines[continent],
                    countryCount: countryCount(on: continent),
                    color: DesignSystem.Color.blue
                ) {
                    coordinator.push(MapRoute.map(continentFilter: continent))
                }
            }
        }
    }

    func countryCount(on continent: Country.Continent) -> Int {
        countryDataService.countries.filter { $0.continent == continent }.count
    }
}

// MARK: - Actions
private extension ContinentsScreen {
    func loadOutlines() async {
        let shapes = await geoJSONCache.loadShapes()
        outlines = await ContinentOutline.silhouettes(for: Self.continents, shapes: shapes)
    }
}
