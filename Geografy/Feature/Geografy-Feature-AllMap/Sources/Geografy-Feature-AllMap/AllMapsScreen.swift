import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct AllMapsScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var blobAnimating = false

    private let continentMaps: [(name: String, icon: String)] = [
        ("Europe", Country.Continent.europe.icon),
        ("Asia", Country.Continent.asia.icon),
        ("Africa", Country.Continent.africa.icon),
        ("North America", Country.Continent.northAmerica.icon),
        ("South America", Country.Continent.southAmerica.icon),
        ("Oceania", Country.Continent.oceania.icon),
    ]

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .background { ambientBackground }
            .navigationTitle("All Maps")
            .onAppear { blobAnimating = true }
    }
}

// MARK: - Content
private extension AllMapsScreen {
    var isLandscape: Bool { verticalSizeClass == .compact }
    var isWideLayout: Bool { horizontalSizeClass == .regular }

    var columns: [GridItem] {
        let minSize: CGFloat = isWideLayout ? 220 : (isLandscape ? 180 : 140)
        let spacing = isLandscape || isWideLayout ? DesignSystem.Spacing.md : DesignSystem.Spacing.sm
        return [GridItem(.adaptive(minimum: minSize), spacing: spacing)]
    }

    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                worldMapHero
                    .padding(.horizontal, DesignSystem.Spacing.md)

                continentSection
            }
            .readableContentWidth(DesignSystem.AdaptiveLayout.maxWideContentWidth)
            .padding(.top, DesignSystem.Spacing.sm)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }
}

// MARK: - World Map Hero
private extension AllMapsScreen {
    var worldMapHero: some View {
        Button { openMap(named: "World") } label: {
            worldMapCard
        }
        .buttonStyle(PressButtonStyle())
    }

    var worldMapCard: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color(hex: "1A237E"), Color(hex: "3949AB")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: "globe")
                .font(DesignSystem.IconSize.hero)
                .foregroundStyle(.white.opacity(0.08))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 30, y: -20)
                .clipped()

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("World Map")
                    .font(DesignSystem.Font.title)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.onAccent)

                Text("Explore all 197 countries")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(.white.opacity(0.75))

                openPill
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .frame(height: isWideLayout ? 240 : (isLandscape ? 180 : 220))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .shadow(color: Color(hex: "1A237E").opacity(0.5), radius: 20, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
        )
    }

    var openPill: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Text("Open")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
            Image(systemName: "arrow.right")
                .font(DesignSystem.Font.caption2)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(.white.opacity(0.2))
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Continent Section
private extension AllMapsScreen {
    var continentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Continents")
                .padding(.horizontal, DesignSystem.Spacing.md)

            continentGrid
        }
    }

    var continentGrid: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.md) {
            ForEach(Array(continentMaps.enumerated()), id: \.offset) { _, map in
                continentCard(name: map.name, icon: map.icon)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func continentCard(name: String, icon: String) -> some View {
        let colors = gradientColors(for: name)
        return Button { openMap(named: name) } label: {
            continentCardLabel(name: name, icon: icon, colors: colors)
        }
        .buttonStyle(PressButtonStyle())
    }

    func continentCardLabel(
        name: String,
        icon: String,
        colors: (Color, Color)
    ) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [colors.0, colors.1],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: icon)
                .font(DesignSystem.IconSize.hero)
                .foregroundStyle(.white.opacity(0.10))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 24, y: -12)
                .clipped()

            continentCardText(name: name)
        }
        .frame(height: isWideLayout ? 180 : (isLandscape ? 130 : 160))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .shadow(color: colors.0.opacity(0.50), radius: 16, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }

    func continentCardText(name: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(name)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.onAccent)

            HStack(spacing: 4) {
                Text("Open")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(.white.opacity(0.9))
                Image(systemName: "arrow.right")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, 4)
            .background(.white.opacity(0.18))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.25), lineWidth: 1))
        }
        .padding(DesignSystem.Spacing.sm)
    }
}

// MARK: - Actions
private extension AllMapsScreen {
    func openMap(named name: String) {
        coordinator.cover(
            .mapFullScreen(continentFilter: name == "World" ? nil : name)
        )
    }
}

// MARK: - Gradient Colors
private extension AllMapsScreen {
    func gradientColors(for name: String) -> (Color, Color) {
        switch name {
        case "Europe": (Color(hex: "1B5E20"), Color(hex: "388E3C"))
        case "Asia": (Color(hex: "B71C1C"), Color(hex: "D32F2F"))
        case "Africa": (Color(hex: "E65100"), Color(hex: "FF8F00"))
        case "North America": (Color(hex: "004D40"), Color(hex: "00695C"))
        case "South America": (Color(hex: "33691E"), Color(hex: "558B2F"))
        case "Oceania": (Color(hex: "01579B"), Color(hex: "0277BD"))
        default: (Color(hex: "1A237E"), Color(hex: "3949AB"))
        }
    }
}

// MARK: - Background
private extension AllMapsScreen {
    var ambientBackground: some View {
        ZStack {
            DesignSystem.Color.background
            accentTopBlob
            indigoBlob
            blueBlob
        }
        .ignoresSafeArea()
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 6).repeatForever(autoreverses: true),
            value: blobAnimating
        )
    }

    var accentTopBlob: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [DesignSystem.Color.accent.opacity(0.30), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 240
                )
            )
            .frame(width: 480, height: 360)
            .blur(radius: 36)
            .offset(x: -100, y: -160)
            .scaleEffect(blobAnimating ? 1.12 : 0.88)
    }

    var indigoBlob: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [DesignSystem.Color.indigo.opacity(0.22), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
            )
            .frame(width: 400, height: 320)
            .blur(radius: 44)
            .offset(x: 160, y: 60)
            .scaleEffect(blobAnimating ? 0.88 : 1.10)
    }

    var blueBlob: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [DesignSystem.Color.blue.opacity(0.16), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 180
                )
            )
            .frame(width: 360, height: 280)
            .blur(radius: 40)
            .offset(x: -80, y: 420)
            .scaleEffect(blobAnimating ? 1.08 : 0.92)
    }
}
