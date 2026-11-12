import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import SwiftUI

public struct MapPuzzleSetupScreen: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedContinent: Country.Continent?
    @State private var showPuzzle = false

    private let continents = Country.Continent.allCases.filter { $0 != .antarctica }

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground(.subtle)
            .navigationTitle("Map Puzzle")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationDestination(isPresented: $showPuzzle) {
                if let continent = selectedContinent {
                    MapPuzzleScreen(continent: continent)
                }
            }
    }
}

// MARK: - Subviews
private extension MapPuzzleSetupScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                headerSection
                continentGrid
                if selectedContinent != nil {
                    startButton
                }
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "puzzlepiece.fill")
                .font(DesignSystem.Font.displaySmall)
                .foregroundStyle(DesignSystem.Color.accent)
                .padding(.bottom, DesignSystem.Spacing.xs)
            Text("Choose a Region")
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Pick a continent and guess where countries belong on the map.")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }

    var continentGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DesignSystem.Spacing.sm) {
            ForEach(continents, id: \.rawValue) { continent in
                continentCard(continent)
            }
        }
    }

    func continentCard(_ continent: Country.Continent) -> some View {
        Button {
            selectedContinent = continent
        } label: {
            CardView {
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: continentIcon(continent))
                        .font(DesignSystem.Font.iconLarge)
                        .foregroundStyle(
                            selectedContinent == continent
                                ? DesignSystem.Color.onAccent
                                : DesignSystem.Color.accent
                        )
                    Text(continent.displayName)
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            selectedContinent == continent
                                ? DesignSystem.Color.onAccent
                                : DesignSystem.Color.textPrimary
                        )
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(DesignSystem.Spacing.md)
                .background(
                    selectedContinent == continent
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.cardBackground
                )
            }
        }
        .buttonStyle(PressButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: selectedContinent)
    }

    var startButton: some View {
        GeoButton("Start Puzzle") {
            showPuzzle = true
        }
        .padding(.top, DesignSystem.Spacing.sm)
    }
    func continentIcon(_ continent: Country.Continent) -> String {
        switch continent {
        case .africa: "sun.max.fill"
        case .asia: "globe.asia.australia.fill"
        case .europe: "globe.europe.africa.fill"
        case .northAmerica: "globe.americas.fill"
        case .southAmerica: "globe.americas"
        case .oceania: "water.waves"
        case .antarctica: "snowflake"
        }
    }
}
