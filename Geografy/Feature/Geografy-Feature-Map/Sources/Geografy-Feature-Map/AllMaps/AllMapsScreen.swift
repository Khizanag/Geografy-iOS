import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct AllMapsScreen: View {
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
            .task(id: "\(projection)-\(palette)") { await loadOutlines() }
    }
}

// MARK: - Content
private extension AllMapsScreen {
    var isWideLayout: Bool { horizontalSizeClass == .regular }

    var columns: [GridItem] {
        let count = isWideLayout ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: DesignSystem.Spacing.sm), count: count)
    }

    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                worldMapCard
                continentSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.sm)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth(DesignSystem.AdaptiveLayout.maxWideContentWidth)
        }
    }
}

// MARK: - World Map
private extension AllMapsScreen {
    var worldMapCard: some View {
        Button { openMap(named: "World") } label: {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                WorldMapThumbnail()
                    .frame(height: isWideLayout ? 220 : 160)
                    .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.nested(inset: DesignSystem.Spacing.md)))
                HStack(alignment: .center, spacing: DesignSystem.Spacing.xs) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text("World Map")
                            .font(DesignSystem.Font.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text("Explore all 197 countries")
                            .font(DesignSystem.Font.subheadline)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                    Spacer(minLength: 0)
                    RowChevron()
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                DesignSystem.Color.cardBackground,
                in: .rect(cornerRadius: DesignSystem.CornerRadius.extraLarge)
            )
            .contentShape(.rect(cornerRadius: DesignSystem.CornerRadius.extraLarge))
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Continents
private extension AllMapsScreen {
    var continentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Continents")

            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
                ForEach(Self.continents, id: \.self) { continent in
                    ContinentTile(
                        continent: continent,
                        outline: outlines[continent],
                        countryCount: countryCount(on: continent),
                        color: DesignSystem.Color.blue
                    ) {
                        openMap(named: continent.displayName)
                    }
                }
            }
        }
    }

    func countryCount(on continent: Country.Continent) -> Int {
        countryDataService.countries.filter { $0.continent == continent }.count
    }
}

// MARK: - Actions
private extension AllMapsScreen {
    func openMap(named name: String) {
        coordinator.cover(
            .mapFullScreen(continentFilter: name == "World" ? nil : name)
        )
    }

    func loadOutlines() async {
        let shapes = await geoJSONCache.loadShapes()
        outlines = await ContinentOutline.silhouettes(for: Self.continents, shapes: shapes)
    }
}
