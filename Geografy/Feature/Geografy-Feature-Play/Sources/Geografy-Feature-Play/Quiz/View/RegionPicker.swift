import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Map
import Geografy_Core_Service
import SwiftUI

/// Picks the region a game draws its countries from: the whole world on top, when the game offers it, then each
/// continent's silhouette, two to a row. Every game's own region type works, through `continent`.
public struct RegionPicker<Region: Hashable>: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(GeoJSONCache.self) private var geoJSONCache
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding private var selection: Region
    private let regions: [Region]
    private let color: Color
    private let continent: (Region) -> Country.Continent?
    private let includes: (Country) -> Bool

    @State private var outlines: [Country.Continent: ContinentOutline] = [:]

    // MARK: - Init
    /// - Parameters:
    ///   - regions: In order; one whose `continent` is nil is the whole world, shown on top.
    ///   - color: The screen's game color, used for the selected region.
    ///   - continent: The continent a region covers, or nil for the whole world.
    ///   - includes: Which countries the game can ask, for the counts on each tile.
    public init(
        selection: Binding<Region>,
        regions: [Region],
        color: Color,
        continent: @escaping (Region) -> Country.Continent?,
        includes: @escaping (Country) -> Bool = { _ in true }
    ) {
        _selection = selection
        self.regions = regions
        self.color = color
        self.continent = continent
        self.includes = includes
    }

    // MARK: - Body
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(regions.filter { continent($0) == nil }, id: \.self) { region in
                WorldRegionTile(
                    countryCount: countryCount(in: region),
                    color: color,
                    isSelected: selection == region
                ) {
                    select(region)
                }
            }
            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
                ForEach(continentRegions, id: \.self) { region in
                    if let continent = continent(region) {
                        ContinentTile(
                            continent: continent,
                            outline: outlines[continent],
                            countryCount: countryCount(in: region),
                            color: color,
                            isSelected: selection == region
                        ) {
                            select(region)
                        }
                    }
                }
            }
        }
        .task { await loadOutlines() }
        .haptic(.selection, trigger: selection)
    }
}

// MARK: - Quiz Regions
public extension RegionPicker where Region == QuizRegion {
    init(selectedRegion: Binding<QuizRegion>, color: Color) {
        self.init(selection: selectedRegion, regions: QuizRegion.allCases, color: color, continent: \.continent)
    }
}

// MARK: - Helpers
private extension RegionPicker {
    var continentRegions: [Region] {
        regions.filter { continent($0) != nil }
    }

    var columns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: DesignSystem.Spacing.sm), count: count)
    }

    func countryCount(in region: Region) -> Int {
        let continent = continent(region)
        return countryDataService.countries.count { country in
            (continent.map { country.continent == $0 } ?? true) && includes(country)
        }
    }

    func select(_ region: Region) {
        guard region != selection else { return }
        selection = region
    }

    func loadOutlines() async {
        guard outlines.isEmpty else { return }
        let shapes = await geoJSONCache.loadShapes()
        outlines = await ContinentOutline.silhouettes(for: continentRegions.compactMap(continent), shapes: shapes)
    }
}

// MARK: - Continent
extension QuizRegion {
    /// The continent a region covers, or nil for the whole world.
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
