import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct AllMapsScreen: View {
    public init() {}
    @Environment(Navigator.self) private var coordinator
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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

    public var body: some View {
        scrollContent
            .background { ambientBackground }
            .navigationTitle("All Maps")
            .onAppear {
                blobAnimating = true
                appeared = true
            }
    }
}

// MARK: - Background
private extension AllMapsScreen {
    var ambientBackground: some View {
        // swiftlint:disable:next closure_body_length
        ZStack {
            DesignSystem.Color.background

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

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.purple.opacity(0.14), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 300)
                .blur(radius: 48)
                .offset(x: 140, y: 700)
                .scaleEffect(blobAnimating ? 0.90 : 1.10)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.accent.opacity(0.12), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 260)
                .blur(radius: 44)
                .offset(x: -60, y: 1_000)
                .scaleEffect(blobAnimating ? 1.06 : 0.94)
        }
        .ignoresSafeArea()
        .animation(reduceMotion ? nil : .easeInOut(duration: 6).repeatForever(autoreverses: true), value: blobAnimating)
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
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                headerSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .feedSection(appeared: appeared, delay: 0.0)

                mapGrid
            }
            .readableContentWidth(DesignSystem.AdaptiveLayout.maxWideContentWidth)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            SectionHeaderView(title: "Explore Maps")
            Text("Tap a region to dive into an interactive map")
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
        // swiftlint:disable:next closure_body_length
        return Button { openMap(named: name) } label: {
            // swiftlint:disable:next closure_body_length
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
            .frame(height: isWideLayout ? 180 : (isLandscape ? 130 : 160))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
            .shadow(color: colors.0.opacity(0.50), radius: 16, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .strokeBorder(.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Helpers
private extension AllMapsScreen {
    func openMap(named name: String) {
        coordinator.sheet(
            .mapFullScreen(continentFilter: name == "World" ? nil : name)
        )
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
