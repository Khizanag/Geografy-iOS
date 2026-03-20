import SwiftUI

struct HomeScreen: View {
    @State private var selectedMapIndex = 0
    @State private var showMap = false
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
                profileSection
                mapCarousel
                actionButtons
            }
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showMap) {
            NavigationStack {
                MapScreen()
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
    }
}

// MARK: - Profile Section

private extension HomeScreen {
    var profileSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            profileTopRow
            currencyRow
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var profileTopRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            profileBadge
            xpProgressBar
            friendsButton
        }
    }

    var profileBadge: some View {
        Button {
            showProfile = true
        } label: {
            ZStack {
                Image(systemName: "star.circle.fill")
                    .font(DesignSystem.IconSize.large)
                    .foregroundStyle(DesignSystem.Color.error)

                Text("5")
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(DesignSystem.Color.accent)
                    .clipShape(Capsule())
                    .offset(x: 14, y: 14)
            }
            .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
    }

    var xpProgressBar: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text("175/190 XP")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .fill(DesignSystem.Color.cardBackground)

                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .fill(DesignSystem.Color.accent)
                        .frame(width: geometry.size.width * (175.0 / 190.0))
                }
            }
            .frame(height: 8)
        }
    }

    var friendsButton: some View {
        Button {
            showFriends = true
        } label: {
            Image(systemName: "person.2.fill")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
    }

    var currencyRow: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            currencyItem(icon: "circle.fill", color: .yellow, value: "1,250")
            currencyItem(icon: "diamond.fill", color: .cyan, value: "45")
            Spacer()
        }
    }

    func currencyItem(icon: String, color: Color, value: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.body)
                .foregroundStyle(color)

            Text(value)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }
}

// MARK: - Map Carousel

private extension HomeScreen {
    var mapCarousel: some View {
        TabView(selection: $selectedMapIndex) {
            ForEach(Array(maps.enumerated()), id: \.offset) { index, map in
                MapCarouselCard(
                    mapName: map.name,
                    systemImage: map.icon
                ) {
                    showMap = true
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.xl)
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 320)
    }
}

// MARK: - Action Buttons

private extension HomeScreen {
    var actionButtons: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            statisticsButton
            playButton
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var statisticsButton: some View {
        NavigationLink(value: NavigationRoute.achievements) {
            GeoCard {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "chart.bar.fill")
                        .font(DesignSystem.Font.title2)
                        .foregroundStyle(.blue)

                    Text("Statistics")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(.plain)
    }

    var playButton: some View {
        NavigationLink(value: NavigationRoute.quiz) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "puzzlepiece.fill")
                    .font(DesignSystem.Font.title2)

                Text("Play")
                    .font(DesignSystem.Font.title2)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Color.accent)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        }
        .buttonStyle(.plain)
    }
}

