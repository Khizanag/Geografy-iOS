import SwiftUI

struct HomeScreen: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @State private var selectedMapIndex = 0
    @State private var showMap = false
    @State private var continentFilter: String?
    @State private var showQuiz = false
    @State private var showProfile = false
    @State private var showFriends = false

    private let maps: [(name: String, icon: String)] = [
        ("World map", "globe"),
        ("Europe", "globe.europe.africa"),
        ("Asia", "globe.asia.australia"),
        ("Africa", "globe.europe.africa"),
        ("North America", "globe.americas"),
        ("South America", "globe.americas"),
        ("Oceania", "globe.asia.australia"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                topBar
                mapCarousel
            }
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .safeAreaInset(edge: .bottom) {
            playButton
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showMap) {
            NavigationStack {
                MapScreen(continentFilter: continentFilter)
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }
        }
        .sheet(isPresented: $showProfile) {
            ComingSoonSheet(title: "Profile", icon: "person.circle.fill")
        }
        .sheet(isPresented: $showFriends) {
            ComingSoonSheet(title: "Friends", icon: "person.2.fill")
        }
        .fullScreenCover(isPresented: $showQuiz) {
            NavigationStack {
                ComingSoonView(icon: "questionmark.circle.fill", title: "Quiz", isDismissible: true)
            }
        }
    }
}

// MARK: - Top Bar

private extension HomeScreen {
    var topBar: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            profileButton
            statsButton
            Spacer()
            friendsButton
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var profileButton: some View {
        Button { showProfile = true } label: {
            Image(systemName: "person.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
                .padding(DesignSystem.Spacing.sm)
        }
        .glassEffect(.regular.interactive(), in: .circle)
    }

    var statsButton: some View {
        Button { showProfile = true } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                xpIndicator
                divider
                currencyItem(icon: "circle.fill", color: .yellow, value: "1,250")
            }
        }
        .buttonStyle(.glass)
        .fixedSize(horizontal: false, vertical: true)
    }

    var friendsButton: some View {
        Button { showFriends = true } label: {
            Image(systemName: "person.2.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
                .padding(DesignSystem.Spacing.sm)
        }
        .glassEffect(.regular.interactive(), in: .circle)
    }
}

// MARK: - Stats Button Content

private extension HomeScreen {
    var xpIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            xpProgressBar

            Text("Lv. 5")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var xpProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DesignSystem.Color.cardBackgroundHighlighted)

                Capsule()
                    .fill(DesignSystem.Color.accent)
                    .frame(width: geo.size.width * (175.0 / 190.0))
            }
        }
        .frame(height: DesignSystem.Size.xs)
    }

    var divider: some View {
        Rectangle()
            .fill(DesignSystem.Color.textTertiary.opacity(0.3))
            .frame(width: DesignSystem.Size.xxs, height: DesignSystem.Size.sm)
    }

    func currencyItem(icon: String, color: Color, value: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(color)

            Text(value)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }
}

// MARK: - Map Carousel

private extension HomeScreen {
    var isLandscape: Bool { verticalSizeClass == .compact }

    var carouselHeight: CGFloat { isLandscape ? 220 : DesignSystem.Size.section }

    var mapCarousel: some View {
        TabView(selection: $selectedMapIndex) {
            ForEach(Array(maps.enumerated()), id: \.offset) { index, map in
                MapCarouselCard(
                    mapName: map.name,
                    systemImage: map.icon,
                    compact: isLandscape
                ) {
                    openMap(named: map.name)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.xl)
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: carouselHeight)
    }
}

// MARK: - Actions

private extension HomeScreen {
    func openMap(named name: String) {
        continentFilter = name == "World map" ? nil : name
        showMap = true
    }
}

// MARK: - Play Button

private extension HomeScreen {
    var playButton: some View {
        Button { showQuiz = true } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "puzzlepiece.fill")
                    .font(DesignSystem.Font.title2)

                Text("Play")
                    .font(DesignSystem.Font.title2)
            }
            .foregroundStyle(DesignSystem.Color.onAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Color.accent)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        }
        .buttonStyle(.plain)
    }
}
