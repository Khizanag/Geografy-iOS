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
        ZStack {
            ambientBackground
            scrollContent
        }
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
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                blobAnimating = true
            }
            withAnimation(.easeOut(duration: 0.6)) {
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
                    colors: [DesignSystem.Color.accent.opacity(0.18), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                ))
                .frame(width: 360, height: 280)
                .blur(radius: 30)
                .offset(x: -60, y: -180)
                .scaleEffect(blobAnimating ? 1.08 : 0.94)

            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.indigo.opacity(0.13), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 160
                ))
                .frame(width: 300, height: 260)
                .blur(radius: 40)
                .offset(x: 120, y: 260)
                .scaleEffect(blobAnimating ? 0.92 : 1.06)

            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.blue.opacity(0.08), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 120
                ))
                .frame(width: 220, height: 180)
                .blur(radius: 30)
                .offset(x: 90, y: -40)
                .scaleEffect(blobAnimating ? 1.05 : 0.95)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Content

private extension AllMapsScreen {
    var isLandscape: Bool { verticalSizeClass == .compact }

    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: isLandscape ? 180 : 150), spacing: DesignSystem.Spacing.md)]
    }

    var scrollContent: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.md) {
                ForEach(Array(maps.enumerated()), id: \.offset) { index, map in
                    mapCard(name: map.name, icon: map.icon)
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.9)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.75)
                                .delay(Double(index) * 0.06),
                            value: appeared
                        )
                }
            }
            .padding(DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.md)
        }
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
