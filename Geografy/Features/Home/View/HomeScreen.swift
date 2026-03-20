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
            VStack(spacing: GeoSpacing.lg) {
                profileSection
                mapCarousel
                actionButtons
            }
            .padding(.vertical, GeoSpacing.md)
        }
        .background(GeoColors.background)
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
        VStack(spacing: GeoSpacing.sm) {
            profileTopRow
            currencyRow
        }
        .padding(.horizontal, GeoSpacing.md)
    }

    var profileTopRow: some View {
        HStack(spacing: GeoSpacing.sm) {
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
                    .font(GeoIconSize.large)
                    .foregroundStyle(GeoColors.error)

                Text("5")
                    .font(GeoFont.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(GeoColors.accent)
                    .clipShape(Capsule())
                    .offset(x: 14, y: 14)
            }
            .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
    }

    var xpProgressBar: some View {
        VStack(alignment: .leading, spacing: GeoSpacing.xxs) {
            Text("175/190 XP")
                .font(GeoFont.caption)
                .foregroundStyle(GeoColors.textSecondary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: GeoCornerRadius.small)
                        .fill(GeoColors.cardBackground)

                    RoundedRectangle(cornerRadius: GeoCornerRadius.small)
                        .fill(GeoColors.accent)
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
                .font(GeoFont.headline)
                .foregroundStyle(GeoColors.textPrimary)
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
    }

    var currencyRow: some View {
        HStack(spacing: GeoSpacing.lg) {
            currencyItem(icon: "circle.fill", color: .yellow, value: "1,250")
            currencyItem(icon: "diamond.fill", color: .cyan, value: "45")
            Spacer()
        }
    }

    func currencyItem(icon: String, color: Color, value: String) -> some View {
        HStack(spacing: GeoSpacing.xs) {
            Image(systemName: icon)
                .font(GeoFont.body)
                .foregroundStyle(color)

            Text(value)
                .font(GeoFont.headline)
                .foregroundStyle(GeoColors.textPrimary)
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
                .padding(.horizontal, GeoSpacing.md)
                .padding(.bottom, GeoSpacing.xl)
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
        VStack(spacing: GeoSpacing.sm) {
            statisticsButton
            playButton
        }
        .padding(.horizontal, GeoSpacing.md)
    }

    var statisticsButton: some View {
        NavigationLink(value: NavigationRoute.achievements) {
            GeoCard {
                HStack(spacing: GeoSpacing.sm) {
                    Image(systemName: "chart.bar.fill")
                        .font(GeoFont.title2)
                        .foregroundStyle(.blue)

                    Text("Statistics")
                        .font(GeoFont.headline)
                        .foregroundStyle(GeoColors.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(GeoFont.subheadline)
                        .foregroundStyle(GeoColors.textTertiary)
                }
                .padding(GeoSpacing.md)
            }
        }
        .buttonStyle(.plain)
    }

    var playButton: some View {
        NavigationLink(value: NavigationRoute.quiz) {
            HStack(spacing: GeoSpacing.sm) {
                Image(systemName: "puzzlepiece.fill")
                    .font(GeoFont.title2)

                Text("Play")
                    .font(GeoFont.title2)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, GeoSpacing.md)
            .background(GeoColors.accent)
            .clipShape(RoundedRectangle(cornerRadius: GeoCornerRadius.large))
        }
        .buttonStyle(.plain)
    }
}

