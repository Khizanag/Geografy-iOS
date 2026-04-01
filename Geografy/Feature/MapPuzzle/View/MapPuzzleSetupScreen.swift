import GeografyCore
import GeografyDesign
import SwiftUI

struct MapPuzzleSetupScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedContinent: Country.Continent?
    @State private var showPuzzle = false
    @State private var blobAnimating = false

    private let continents = Country.Continent.allCases.filter { $0 != .antarctica }

    var body: some View {
        scrollContent
            .background { ambientBlobs }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Map Puzzle")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { startBlobAnimation() }
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

    var ambientBlobs: some View {
        ZStack {
            blobEllipse(color: DesignSystem.Color.accent, opacity: 0.22, offset: (-100, -200), animates: blobAnimating)
            blobEllipse(color: DesignSystem.Color.purple, opacity: 0.18, offset: (160, 300), animates: !blobAnimating)
        }
        .allowsHitTesting(false)
        .animation(reduceMotion ? nil : .easeInOut(duration: 6).repeatForever(autoreverses: true), value: blobAnimating)
    }

    func blobEllipse(color: Color, opacity: Double, offset: (CGFloat, CGFloat), animates: Bool) -> some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [color.opacity(opacity), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
            )
            .frame(width: 400, height: 320)
            .blur(radius: 40)
            .offset(x: offset.0, y: offset.1)
            .scaleEffect(animates ? 1.08 : 0.92)
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

// MARK: - Actions
private extension MapPuzzleSetupScreen {
    func startBlobAnimation() {
        blobAnimating = true
    }
}
