import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct MapPuzzleSetupScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService

    /// A continent's raw value, or `worldKey` for the whole world.
    @AppStorage("mapPuzzle_selectedContinent") private var storedRegion = Self.worldKey

    /// The whole world on top, then each continent, as in every game's region choice.
    private let regions: [Country.Continent?] = [nil] + Country.Continent.allCases.filter { $0 != .antarctica }
    private let gameColor = DesignSystem.Color.purple

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Map Puzzle")
            .navigationBarTitleDisplayMode(.inline)
            .gameGuide(.mapPuzzle)
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
                selection: selectedRegion,
                regions: regions,
                color: gameColor,
                continent: { $0 }
            )
        }
    }

    var startButton: some View {
        GlassButton("Start Puzzle", systemImage: "play.fill", fullWidth: true) {
            coordinator.cover(PlayRoute.mapPuzzleGame(continent: selectedRegion.wrappedValue))
        }
        .disabled(!MapPuzzleRules.isPlayable(countryCount: countryCount(for: selectedRegion.wrappedValue)))
        .accessibilityHint("Starts a puzzle in \(regionName)")
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Helpers
private extension MapPuzzleSetupScreen {
    var headerFacts: [GameIntroHeader.Fact] {
        let countryCount = countryCount(for: selectedRegion.wrappedValue)
        let questionCount = MapPuzzleRules.questionCount(forCountryCount: countryCount)
        guard questionCount > 0 else { return [] }
        let minutes = MapPuzzleRules.estimatedMinutes(forQuestionCount: questionCount)
        return [
            GameIntroHeader.Fact("\(questionCount) rounds", systemImage: "list.number"),
            GameIntroHeader.Fact("\(MapPuzzleRules.optionsPerQuestion) choices each", systemImage: "square.grid.2x2"),
            GameIntroHeader.Fact("About \(minutes) min", systemImage: "clock"),
        ]
    }

    static let worldKey = "world"

    var selectedRegion: Binding<Country.Continent?> {
        Binding {
            Country.Continent(rawValue: storedRegion)
        } set: { region in
            storedRegion = region?.rawValue ?? Self.worldKey
        }
    }

    var regionName: String {
        selectedRegion.wrappedValue?.displayName ?? String(localized: "the whole world", bundle: .module)
    }

    func countryCount(for continent: Country.Continent?) -> Int {
        guard let continent else { return countryDataService.countries.count { $0.continent != .antarctica } }
        return countryDataService.countries.count { $0.continent == continent }
    }
}
