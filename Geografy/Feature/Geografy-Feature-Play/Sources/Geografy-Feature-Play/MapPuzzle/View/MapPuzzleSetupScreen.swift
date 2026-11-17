import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct MapPuzzleSetupScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService

    @AppStorage("mapPuzzle_selectedContinent") private var selectedContinent: Country.Continent = .europe

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
            subtitle: "Name the country highlighted on the map.",
            systemImage: "puzzlepiece.fill",
            color: gameColor,
            facts: headerFacts
        )
    }

    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Region")
            RegionPicker(
                selection: $selectedContinent,
                regions: continents,
                color: gameColor,
                continent: { $0 }
            )
        }
    }

    var startButton: some View {
        GlassButton("Start Puzzle", systemImage: "play.fill", fullWidth: true) {
            coordinator.push(PlayRoute.mapPuzzleGame(continent: selectedContinent))
        }
        .disabled(!MapPuzzleRules.isPlayable(countryCount: countryCount(for: selectedContinent)))
        .accessibilityHint("Starts a puzzle in \(selectedContinent.displayName)")
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
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
