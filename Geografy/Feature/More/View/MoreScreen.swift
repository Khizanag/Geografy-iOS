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
        case profile, countries, orgs, favorites, travel, achievements, leaderboards, themes, settings

        var id: Self { self }

        var label: String {
            switch self {
            case .profile: "Profile"
            case .countries: "Countries"
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
            case .countries: "list.bullet"
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
            case .countries: "Browse all 197 countries"
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
            case .countries: DesignSystem.Color.blue
            case .orgs: DesignSystem.Color.indigo
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
        ZStack {
            blobEllipse(BlobConfig(
                color: DesignSystem.Color.accent, opacity: 0.28,
                endRadius: 220, width: 440, height: 320, blur: 32,
                offset: (-80, -80), scale: blobAnimating ? 1.10 : 0.90
            ))
            blobEllipse(BlobConfig(
                color: DesignSystem.Color.indigo, opacity: 0.20,
                endRadius: 180, width: 360, height: 300, blur: 40,
                offset: (140, 80), scale: blobAnimating ? 0.88 : 1.10
            ))
            blobEllipse(BlobConfig(
                color: DesignSystem.Color.blue, opacity: 0.14,
                endRadius: 160, width: 320, height: 260, blur: 36,
                offset: (-100, 400), scale: blobAnimating ? 1.06 : 0.94
            ))
            blobEllipse(BlobConfig(
                color: DesignSystem.Color.purple, opacity: 0.12,
                endRadius: 160, width: 320, height: 280, blur: 44,
                offset: (160, 650), scale: blobAnimating ? 0.92 : 1.08
            ))
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    struct BlobConfig {
        let color: Color
        let opacity: Double
        let endRadius: CGFloat
        let width: CGFloat
        let height: CGFloat
        let blur: CGFloat
        let offset: (CGFloat, CGFloat)
        let scale: CGFloat
    }

    func blobEllipse(_ config: BlobConfig) -> some View {
        Ellipse()
            .fill(RadialGradient(
                colors: [config.color.opacity(config.opacity), .clear],
                center: .center,
                startRadius: 0,
                endRadius: config.endRadius
            ))
            .frame(width: config.width, height: config.height)
            .blur(radius: config.blur)
            .offset(x: config.offset.0, y: config.offset.1)
            .scaleEffect(config.scale)
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
        [.profile, .countries, .orgs, .favorites, .travel, .achievements, .leaderboards, .themes, .settings]
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
    func sheetContent(for sheet: MoreSheet) -> some View {
        NavigationStack {
            Group {
                switch sheet {
                case .profile:
                    ProfileScreen()
                case .countries:
                    CountryListScreen()
                        .navigationDestination(for: Country.self) { country in
                            CountryDetailScreen(country: country)
                        }
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
