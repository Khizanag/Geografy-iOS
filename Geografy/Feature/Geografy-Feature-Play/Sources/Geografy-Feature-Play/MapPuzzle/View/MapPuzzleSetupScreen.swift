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
    @AppStorage("mapPuzzle_questionCount") private var questionCount: QuestionCount = .ten

    /// The whole world on top, then each continent, as in every game's region choice.
    private let regions: [Country.Continent?] = [nil] + Country.Continent.allCases.filter { $0 != .antarctica }
    private let gameColor = DesignSystem.Color.purple
    private let initialContinent: Country.Continent?

    @State private var hasChosenInitialRegion = false

    // MARK: - Init
    /// - Parameter continent: The continent to choose on arrival, as a continent's map asks; nil keeps the last
    ///   choice.
    public init(continent: Country.Continent? = nil) {
        initialContinent = continent
    }

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Map Puzzle")
            .navigationBarTitleDisplayMode(.inline)
            .gameGuide(.mapPuzzle)
            .safeAreaBar(edge: .bottom) { startButton }
            .onAppear { chooseInitialRegion() }
    }
}

// MARK: - Subviews
private extension MapPuzzleSetupScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                header
                regionSection
                gameSection
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        .setupSectionScrolling()
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
                .id(SetupSection.region)
            RegionPicker(
                selection: selectedRegion,
                regions: regions,
                color: gameColor,
                continent: { $0 }
            )
        }
    }

    var gameSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Game")
                .id(SetupSection.game)
            CardView {
                OptionPickerRow(
                    "Rounds",
                    selection: $questionCount,
                    options: QuestionCount.allCases,
                    note: roundsNote,
                    label: \.displayName
                )
                .padding(DesignSystem.Spacing.md)
            }
        }
    }

    var startButton: some View {
        GlassButton("Start Puzzle", systemImage: "play.fill", fullWidth: true) {
            coordinator.cover(
                PlayRoute.mapPuzzleGame(continent: selectedRegion.wrappedValue, questionCount: questionCount)
            )
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
        let rounds = MapPuzzleRules.questionCount(requested: questionCount, countryCount: countryCount)
        guard rounds > 0 else { return [] }
        let minutes = MapPuzzleRules.estimatedMinutes(forQuestionCount: rounds)
        return [
            GameIntroHeader.Fact(regionTitle, systemImage: "globe", showing: SetupSection.region),
            GameIntroHeader.Fact("\(rounds) rounds", systemImage: "list.number", showing: SetupSection.game),
            GameIntroHeader.Fact("\(MapPuzzleRules.optionsPerQuestion) choices each", systemImage: "square.grid.2x2"),
            GameIntroHeader.Fact("About \(minutes) min", systemImage: "clock"),
        ]
    }

    static let worldKey = "world"

    /// Says so when the chosen region has fewer countries than the rounds chosen.
    var roundsNote: String? {
        let countryCount = countryCount(for: selectedRegion.wrappedValue)
        guard MapPuzzleRules.isPlayable(countryCount: countryCount), countryCount < questionCount.rawValue else {
            return nil
        }
        return String(
            localized: "\(regionName) has \(countryCount) countries, so a round asks \(countryCount).",
            bundle: .module
        )
    }

    /// Once only, so a region changed here isn't put back when a finished puzzle returns to setup.
    func chooseInitialRegion() {
        guard !hasChosenInitialRegion else { return }
        hasChosenInitialRegion = true
        if let initialContinent {
            storedRegion = initialContinent.rawValue
        }
    }

    var selectedRegion: Binding<Country.Continent?> {
        Binding {
            Country.Continent(rawValue: storedRegion)
        } set: { region in
            storedRegion = region?.rawValue ?? Self.worldKey
        }
    }

    /// The region as a title, for the header's fact.
    var regionTitle: String {
        selectedRegion.wrappedValue?.displayName ?? String(localized: "Whole World", bundle: .module)
    }

    var regionName: String {
        selectedRegion.wrappedValue?.displayName ?? String(localized: "the whole world", bundle: .module)
    }

    func countryCount(for continent: Country.Continent?) -> Int {
        guard let continent else { return countryDataService.countries.count { $0.continent != .antarctica } }
        return countryDataService.countries.count { $0.continent == continent }
    }
}
