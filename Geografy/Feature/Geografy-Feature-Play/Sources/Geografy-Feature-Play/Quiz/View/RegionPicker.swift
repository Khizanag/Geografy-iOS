import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Map
import Geografy_Core_Service
import SwiftUI

/// Picks the region a game draws its countries from: the whole world on top, then each continent's silhouette,
/// two to a row.
public struct RegionPicker: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(GeoJSONCache.self) private var geoJSONCache
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding private var selectedRegion: QuizRegion
    private let color: Color

    @State private var outlines: [Country.Continent: ContinentOutline] = [:]

    private static let continentRegions = QuizRegion.allCases.filter { $0 != .world }

    // MARK: - Init
    /// - Parameter color: The screen's game color, used for the selected region.
    public init(selectedRegion: Binding<QuizRegion>, color: Color) {
        _selectedRegion = selectedRegion
        self.color = color
    }

    // MARK: - Body
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            WorldRegionTile(
                countryCount: countryCount(in: .world),
                color: color,
                isSelected: selectedRegion == .world
            ) {
                select(.world)
            }
            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
                ForEach(Self.continentRegions) { region in
                    if let continent = region.continent {
                        ContinentTile(
                            continent: continent,
                            outline: outlines[continent],
                            countryCount: countryCount(in: region),
                            color: color,
                            isSelected: selectedRegion == region
                        ) {
                            select(region)
                        }
                    }
                }
            }
        }
        .task { await loadOutlines() }
    }
}

// MARK: - Helpers
private extension RegionPicker {
    var columns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: DesignSystem.Spacing.sm), count: count)
    }

    func countryCount(in region: QuizRegion) -> Int {
        region.filter(countryDataService.countries).count
    }

    func select(_ region: QuizRegion) {
        guard region != selectedRegion else { return }
        #if !os(tvOS)
        hapticsService.selection()
        #endif
        selectedRegion = region
    }

    func loadOutlines() async {
        guard outlines.isEmpty else { return }
        let shapes = await geoJSONCache.loadShapes()
        let continents = Self.continentRegions.compactMap(\.continent)
        outlines = await ContinentOutline.silhouettes(for: continents, shapes: shapes)
    }
}

// MARK: - Continent
private extension QuizRegion {
    var continent: Country.Continent? {
        switch self {
        case .world: nil
        case .africa: .africa
        case .asia: .asia
        case .europe: .europe
        case .northAmerica: .northAmerica
        case .southAmerica: .southAmerica
        case .oceania: .oceania
        }
    }
}
