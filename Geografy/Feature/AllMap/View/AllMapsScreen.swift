import SwiftUI

struct AllMapsScreen: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @State private var mapTarget: MapTarget?
    @State private var blobAnimating = false
    @State private var appeared = false

    private let maps: [(name: String, icon: String)] = [
        ("World", "globe"),
        ("Europe", "globe.europe.africa"),
        ("Asia", "globe.asia.australia"),
        ("Africa", "globe.europe.africa"),
        ("North America", "globe.americas"),
        ("South America", "globe.americas"),
        ("Oceania", "globe.asia.australia"),
    ]

    var body: some View {
        scrollContent
            .background { ambientBackground }
        .navigationTitle("All Maps")
        .fullScreenCover(item: $mapTarget) { target in
            NavigationStack {
                MapScreen(continentFilter: target.continentFilter)
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                blobAnimating = true
            }
            withAnimation(.easeOut(duration: 0.7)) {
                appeared = true
            }
        }
    }
}

// MARK: - Background

private extension AllMapsScreen {
    var ambientBackground: some View {
        ZStack {
            DesignSystem.Color.background

            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.accent.opacity(0.26), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 220
                ))
                .frame(width: 440, height: 320)
                .blur(radius: 32)
                .offset(x: -80, y: -200)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)

            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.indigo.opacity(0.18), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 180
                ))
                .frame(width: 360, height: 300)
                .blur(radius: 40)
                .offset(x: 140, y: 100)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)

            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.blue.opacity(0.12), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 160
                ))
                .frame(width: 320, height: 260)
                .blur(radius: 36)
                .offset(x: -100, y: 400)
                .scaleEffect(blobAnimating ? 1.06 : 0.94)

            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.purple.opacity(0.10), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 160
                ))
                .frame(width: 300, height: 280)
                .blur(radius: 44)
                .offset(x: 160, y: 650)
                .scaleEffect(blobAnimating ? 0.92 : 1.08)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Content

private extension AllMapsScreen {
    var isLandscape: Bool { verticalSizeClass == .compact }

    var columns: [GridItem] {
        let minSize: CGFloat = isLandscape ? 180 : 140
        let spacing = isLandscape ? DesignSystem.Spacing.md : DesignSystem.Spacing.sm
        return [GridItem(.adaptive(minimum: minSize), spacing: spacing)]
    }

    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                headerSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .feedSection(appeared: appeared, delay: 0.0)

                mapGrid
            }
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            SectionHeaderView(title: "Explore Maps")
            Text("Choose a region to dive into")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var mapGrid: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.md) {
            ForEach(Array(maps.enumerated()), id: \.offset) { index, map in
                mapCard(name: map.name, icon: map.icon)
                    .feedSection(appeared: appeared, delay: Double(index) * 0.06 + 0.08)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func mapCard(name: String, icon: String) -> some View {
        let colors = gradientColors(for: name)
        return Button { openMap(named: name) } label: {
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
            .frame(height: isLandscape ? 130 : 160)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
            .shadow(color: colors.0.opacity(0.45), radius: 14, y: 5)
        }
        .buttonStyle(GeoPressButtonStyle())
    }
}

// MARK: - Helpers

private extension AllMapsScreen {
    func openMap(named name: String) {
        mapTarget = MapTarget(continentFilter: name == "World" ? nil : name)
    }

    func gradientColors(for name: String) -> (Color, Color) {
        switch name {
        case "World":
            (Color(hex: "1A237E"), Color(hex: "3949AB"))
        case "Europe":
            (Color(hex: "1B5E20"), Color(hex: "388E3C"))
        case "Asia":
            (Color(hex: "B71C1C"), Color(hex: "D32F2F"))
        case "Africa":
            (Color(hex: "E65100"), Color(hex: "FF8F00"))
        case "North America":
            (Color(hex: "004D40"), Color(hex: "00695C"))
        case "South America":
            (Color(hex: "33691E"), Color(hex: "558B2F"))
        case "Oceania":
            (Color(hex: "01579B"), Color(hex: "0277BD"))
        default:
            (Color(hex: "1A237E"), Color(hex: "3949AB"))
        }
    }
}

// MARK: - Feed Section Modifier

private extension View {
    func feedSection(appeared: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(delay), value: appeared)
    }
}
