import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct MapPuzzleSetupScreen: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(GeoJSONCache.self) private var geoJSONCache

    @AppStorage("mapPuzzle_selectedContinent") private var selectedContinent: Country.Continent = .europe

    @State private var outlines: [Country.Continent: ContinentOutline] = [:]
    @State private var showPuzzle = false

    private let continents = Country.Continent.allCases.filter { $0 != .antarctica }
    private let gameColor = DesignSystem.Color.purple

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Map Puzzle")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaBar(edge: .bottom) { startButton }
            .task { await loadOutlines() }
            .navigationDestination(isPresented: $showPuzzle) {
                MapPuzzleScreen(continent: selectedContinent)
            }
    }
}

// MARK: - Subviews
private extension MapPuzzleSetupScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                header
                regionSection
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .scrollEdgeEffectStyle(.soft, for: .bottom)
    }

    var header: some View {
        GameIntroHeader(
            title: "Map Puzzle",
            subtitle: "Find each country among four from the same region.",
            systemImage: "puzzlepiece.fill",
            color: gameColor,
            facts: headerFacts
        )
    }

    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Region")
            AdaptiveGrid(compactMinimum: 140, regularMinimum: 180) {
                ForEach(continents, id: \.self) { continent in
                    ContinentTile(
                        continent: continent,
                        outline: outlines[continent],
                        countryCount: countryCount(for: continent),
                        color: gameColor,
                        isSelected: continent == selectedContinent
                    ) {
                        selectedContinent = continent
                    }
                }
            }
        }
    }

    var startButton: some View {
        GlassButton("Start Puzzle", systemImage: "play.fill", fullWidth: true) {
            showPuzzle = true
        }
        .disabled(!MapPuzzleRules.isPlayable(countryCount: countryCount(for: selectedContinent)))
        .accessibilityHint("Starts a puzzle in \(selectedContinent.displayName)")
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Actions
private extension MapPuzzleSetupScreen {
    func loadOutlines() async {
        guard outlines.isEmpty else { return }
        let shapes = await geoJSONCache.loadShapes()
        outlines = ContinentOutline.outlines(for: continents, shapes: shapes)
    }
}

// MARK: - Helpers
private extension MapPuzzleSetupScreen {
    var headerFacts: [GameIntroHeader.Fact] {
        let questionCount = MapPuzzleRules.questionCount(forCountryCount: countryCount(for: selectedContinent))
        guard questionCount > 0 else { return [] }
        let minutes = MapPuzzleRules.estimatedMinutes(forQuestionCount: questionCount)
        return [
            GameIntroHeader.Fact("\(questionCount) rounds", systemImage: "list.number"),
            GameIntroHeader.Fact("\(MapPuzzleRules.optionsPerQuestion) choices each", systemImage: "square.grid.2x2"),
            GameIntroHeader.Fact("About \(minutes) min", systemImage: "clock"),
        ]
    }

    func countryCount(for continent: Country.Continent) -> Int {
        countryDataService.countries.count { $0.continent == continent }
    }
}
