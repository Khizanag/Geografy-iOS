import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import Geografy_Feature_Map
import SwiftUI

/// Sets up a Pin Drop game: the region, how many rounds, and how small the countries get.
public struct PinDropSetupScreen: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(GeoJSONCache.self) private var geoJSONCache
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.locale) private var locale

    @AppStorage("pinDrop_region") private var region: PinDropRegion = .europe
    @AppStorage("pinDrop_difficulty") private var difficulty: PinDropDifficulty = .standard
    @AppStorage("pinDrop_roundCount") private var roundCount = 10
    @AppStorage("pinDrop_showsBorders") private var showsBorders = true

    @State private var outlines: [Country.Continent: ContinentOutline] = [:]
    @State private var activeGame: PinDropConfiguration?

    private let continents: [PinDropRegion] = PinDropRegion.allCases.filter { $0 != .world }

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Pin Drop")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaBar(edge: .bottom) { startButton }
            .task { await loadOutlines() }
            .navigationDestination(item: $activeGame) { configuration in
                PinDropScreen(configuration: configuration)
            }
    }
}

// MARK: - Subviews
private extension PinDropSetupScreen {
    var configuration: PinDropConfiguration {
        PinDropConfiguration(region: region, difficulty: difficulty, roundCount: roundCount, showsBorders: showsBorders)
    }

    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                header
                regionSection
                optionsSection
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .scrollEdgeEffectStyle(.soft, for: .bottom)
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
            GameIntroHeader.Fact(String(localized: "\(roundCount) rounds", in: locale), systemImage: "list.number"),
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

    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Region")
            worldTile
            LazyVGrid(columns: regionColumns, spacing: DesignSystem.Spacing.sm) {
                ForEach(continents) { option in
                    if let continent = option.continent {
                        ContinentTile(
                            continent: continent,
                            outline: outlines[continent],
                            countryCount: countryCount(for: option),
                            color: PinDropStyle.gameColor,
                            isSelected: region == option
                        ) {
                            region = option
                        }
                    }
                }
            }
        }
    }

    var worldTile: some View {
        Button {
            region = .world
        } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                WorldMapThumbnail(northwardShift: 0.05)
                    .frame(width: 96, height: 56)
                    .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.small))
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Whole World")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("\(countryCount(for: .world)) countries")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer(minLength: 0)
                SelectionMark(isSelected: region == .world, color: PinDropStyle.gameColor)
            }
            .padding(DesignSystem.Spacing.md)
            .selectableTileBackground(isSelected: region == .world, color: PinDropStyle.gameColor)
            .contentShape(.rect(cornerRadius: DesignSystem.CornerRadius.extraLarge))
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel("Whole World")
        .accessibilityAddTraits(region == .world ? .isSelected : [])
    }

    var regionColumns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: DesignSystem.Spacing.sm), count: count)
    }

    var optionsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Game")
            CardView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    OptionPickerRow(
                        "Rounds",
                        selection: roundOption,
                        options: PinDropConfiguration.roundCounts.map(RoundOption.init)
                    ) { "\($0.count)" }
                    OptionPickerRow(
                        "Countries",
                        selection: $difficulty,
                        options: PinDropDifficulty.allCases,
                        note: difficulty == .expert ? "Microstates and islands included" : nil
                    ) { option in
                        switch option {
                        case .standard: "Large"
                        case .expert: "All"
                        }
                    }
                    Divider()
                    bordersToggle
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
    }

    var bordersToggle: some View {
        Toggle(isOn: $showsBorders.animation()) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text("Show Borders")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(
                    showsBorders
                        ? "Countries are outlined and tinted apart"
                        : "Only coastlines. Harder, with its own record"
                )
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .contentTransition(.opacity)
            }
        }
        .tint(PinDropStyle.gameColor)
    }

    var startButton: some View {
        GlassButton("Start", systemImage: "mappin.and.ellipse", fullWidth: true) {
            activeGame = configuration
        }
        .disabled(countryCount(for: region) == 0)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
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

    func loadOutlines() async {
        guard outlines.isEmpty else { return }
        let shapes = await geoJSONCache.loadShapes()
        outlines = await ContinentOutline.silhouettes(for: continents.compactMap(\.continent), shapes: shapes)
    }
}

// MARK: - Round Option
private extension PinDropSetupScreen {
    /// A round count as a picker option, which needs to be identifiable.
    struct RoundOption: Hashable, Identifiable {
        let count: Int

        var id: Int { count }
    }

    var roundOption: Binding<RoundOption> {
        Binding {
            RoundOption(count: roundCount)
        } set: { option in
            roundCount = option.count
        }
    }
}
