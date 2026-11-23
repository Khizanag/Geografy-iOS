import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

/// Sets up a Pin Drop game: the region, how many rounds, and how small the countries get.
public struct PinDropSetupScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.locale) private var locale

    @AppStorage("pinDrop_region") private var region: PinDropRegion = .europe
    @AppStorage("pinDrop_difficulty") private var difficulty: PinDropDifficulty = .standard
    @AppStorage("pinDrop_roundCount") private var roundCount = 10
    @AppStorage("pinDrop_showsBorders") private var showsBorders = true

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Pin Drop")
            .navigationBarTitleDisplayMode(.inline)
            .gameGuide(.pinDrop)
            .bottomActionBar { startButton }
    }
}

// MARK: - Subviews
private extension PinDropSetupScreen {
    var configuration: PinDropConfiguration {
        PinDropConfiguration(region: region, difficulty: difficulty, roundCount: roundCount, showsBorders: showsBorders)
    }

    var configurationBinding: Binding<PinDropConfiguration> {
        Binding {
            configuration
        } set: { new in
            region = new.region
            difficulty = new.difficulty
            roundCount = new.roundCount
            showsBorders = new.showsBorders
        }
    }

    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                header
                PinDropSettingsSections(configuration: configurationBinding)
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        .setupSectionScrolling()
    }

    var header: some View {
        GameIntroHeader(
            title: "Pin Drop",
            subtitle: "We name a country, you find it on the map. A hit is a bullseye; the closer, the more you score.",
            systemImage: "mappin.and.ellipse",
            color: PinDropStyle.gameColor,
            facts: headerFacts
        )
    }

    var headerFacts: [GameIntroHeader.Fact] {
        // Facts take plain text, so it's looked up in the chosen language here.
        var facts = [
            GameIntroHeader.Fact(region.displayName, systemImage: "globe", showing: SetupSection.region),
            GameIntroHeader.Fact(
                String(localized: "\(roundCount) rounds", in: locale),
                systemImage: "list.number",
                showing: SetupSection.game
            ),
            GameIntroHeader.Fact(String(localized: "Bonus for speed", in: locale), systemImage: "bolt.fill"),
        ]
        let best = PinDropRecords().best(for: configuration)
        if best > 0 {
            let points = PinDropStyle.points(Double(best), locale: locale)
            let fact = GameIntroHeader.Fact(String(localized: "Best \(points)", in: locale), systemImage: "trophy.fill")
            facts.append(fact)
        }
        return facts
    }

    var startButton: some View {
        GlassButton("Start", systemImage: "mappin.and.ellipse", fullWidth: true) {
            coordinator.cover(PlayLocalRoute.pinDropGame(configuration))
        }
        .disabled(countryCount(for: region) == 0)
    }
}

// MARK: - Helpers
private extension PinDropSetupScreen {
    func countryCount(for option: PinDropRegion) -> Int {
        countryDataService.countries.count { country in
            (option.continent.map { country.continent == $0 } ?? true)
                && country.area >= difficulty.minimumArea
        }
    }
}
