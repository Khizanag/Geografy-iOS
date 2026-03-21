import SwiftUI

struct MoreScreen: View {
    @State private var activeSheet: MoreSheet?
    @State private var blobAnimating = false

    var body: some View {
        NavigationStack {
            itemList
                .background {
                    ambientBlobs
                }
                .background(DesignSystem.Color.background.ignoresSafeArea())
                .navigationTitle("More")
                .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $activeSheet) { sheet in
            sheetContent(for: sheet)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                blobAnimating = true
            }
        }
    }
}

// MARK: - Sheet Type

private extension MoreScreen {
    enum MoreSheet: Identifiable {
        case profile, orgs, favorites, travel, achievements, leaderboards, themes, settings

        var id: Self { self }

        var label: String {
            switch self {
            case .profile: "Profile"
            case .orgs: "Organizations"
            case .favorites: "Favorites"
            case .travel: "Travel Tracker"
            case .achievements: "Achievements"
            case .leaderboards: "Leaderboards"
            case .themes: "Themes"
            case .settings: "Settings"
            }
        }

        var icon: String {
            switch self {
            case .profile: "person.fill"
            case .orgs: "building.2.fill"
            case .favorites: "heart.fill"
            case .travel: "airplane.departure"
            case .achievements: "trophy.fill"
            case .leaderboards: "list.number"
            case .themes: "paintbrush.fill"
            case .settings: "gearshape.fill"
            }
        }

        var subtitle: String {
            switch self {
            case .profile: "View your stats and level"
            case .orgs: "International organizations"
            case .favorites: "Your saved countries"
            case .travel: "Track your adventures"
            case .achievements: "Unlock badges and rewards"
            case .leaderboards: "Compete with others"
            case .themes: "Customize your experience"
            case .settings: "App preferences"
            }
        }

        var color: Color {
            switch self {
            case .profile: DesignSystem.Color.accent
            case .orgs: DesignSystem.Color.blue
            case .favorites: DesignSystem.Color.error
            case .travel: Color(hex: "00C9A7")
            case .achievements: DesignSystem.Color.warning
            case .leaderboards: DesignSystem.Color.success
            case .themes: DesignSystem.Color.indigo
            case .settings: DesignSystem.Color.textSecondary
            }
        }
    }
}

// MARK: - Subviews

private extension MoreScreen {
    var ambientBlobs: some View {
        // swiftlint:disable line_length
        ZStack {
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.accent.opacity(0.28), .clear], center: .center, startRadius: 0, endRadius: 220))
                .frame(width: 440, height: 320).blur(radius: 32)
                .offset(x: -80, y: -80)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.indigo.opacity(0.20), .clear], center: .center, startRadius: 0, endRadius: 180))
                .frame(width: 360, height: 300).blur(radius: 40)
                .offset(x: 140, y: 80)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.blue.opacity(0.14), .clear], center: .center, startRadius: 0, endRadius: 160))
                .frame(width: 320, height: 260).blur(radius: 36)
                .offset(x: -100, y: 400)
                .scaleEffect(blobAnimating ? 1.06 : 0.94)
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.purple.opacity(0.12), .clear], center: .center, startRadius: 0, endRadius: 160))
                .frame(width: 320, height: 280).blur(radius: 44)
                .offset(x: 160, y: 650)
                .scaleEffect(blobAnimating ? 0.92 : 1.08)
            // swiftlint:enable line_length
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    var itemList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(allSheets, id: \.id) { sheet in
                    rowButton(for: sheet)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
    }

    var allSheets: [MoreSheet] {
        [.profile, .orgs, .favorites, .travel, .achievements, .leaderboards, .themes, .settings]
    }

    func rowButton(for sheet: MoreSheet) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            activeSheet = sheet
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .fill(sheet.color.opacity(0.15))
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .strokeBorder(sheet.color.opacity(0.3), lineWidth: 1)
                    Image(systemName: sheet.icon)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(sheet.color)
                }
                .frame(width: DesignSystem.Size.lg, height: DesignSystem.Size.lg)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(sheet.label)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .lineLimit(1)

                    Text(sheet.subtitle)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(sheet.color.opacity(0.6))
            }
            .padding(DesignSystem.Spacing.sm)
            .background(DesignSystem.Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .strokeBorder(sheet.color.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(GeoPressButtonStyle())
    }

    @ViewBuilder
    // swiftlint:disable:next function_body_length
    func sheetContent(for sheet: MoreSheet) -> some View {
        NavigationStack {
            Group {
                switch sheet {
                case .profile:
                    ProfileScreen()
                case .orgs:
                    OrganizationsScreen()
                case .favorites:
                    FavoritesScreen()
                        .navigationDestination(for: Country.self) { country in
                            CountryDetailScreen(country: country)
                        }
                case .travel:
                    TravelTrackerScreen()
                        .navigationDestination(for: Country.self) { country in
                            CountryDetailScreen(country: country)
                        }
                case .achievements:
                    AchievementsScreen()
                        .navigationTitle("Achievements")
                        .navigationBarTitleDisplayMode(.large)
                case .leaderboards:
                    LeaderboardScreen()
                case .themes:
                    ThemesScreen()
                        .navigationTitle("Themes")
                        .navigationBarTitleDisplayMode(.large)
                case .settings:
                    SettingsScreen()
                }
            }
            .toolbar {
                if sheet != .profile {
                    ToolbarItem(placement: .topBarTrailing) {
                        GeoCircleCloseButton { activeSheet = nil }
                    }
                }
            }
        }
        .presentationDetents([.large])
    }
}
