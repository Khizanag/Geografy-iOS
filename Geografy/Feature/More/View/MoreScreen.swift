import SwiftUI

struct MoreScreen: View {
    @State private var activeSheet: MoreSheet?
    @State private var blobAnimating = false

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Color.background.ignoresSafeArea()
                ambientBlobs
                itemList
            }
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
                    Circle()
                        .fill(sheet.color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: sheet.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(sheet.color)
                }
                Text(sheet.label)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .padding(DesignSystem.Spacing.sm)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        }
        .buttonStyle(GeoPressButtonStyle())
    }

    @ViewBuilder
    // swiftlint:disable:next function_body_length
    func sheetContent(for sheet: MoreSheet) -> some View {
        switch sheet {
        case .profile:
            NavigationStack {
                ProfileScreen()
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.automatic)

        case .orgs:
            NavigationStack {
                OrganizationsScreen()
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.automatic)

        case .favorites:
            NavigationStack {
                FavoritesScreen()
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.automatic)

        case .travel:
            NavigationStack {
                TravelTrackerScreen()
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.automatic)

        case .achievements:
            NavigationStack {
                AchievementsScreen()
                    .navigationTitle("Achievements")
                    .navigationBarTitleDisplayMode(.large)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.automatic)

        case .leaderboards:
            NavigationStack {
                LeaderboardScreen()
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.automatic)

        case .themes:
            NavigationStack {
                ThemesScreen()
                    .navigationTitle("Themes")
                    .navigationBarTitleDisplayMode(.large)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.automatic)

        case .settings:
            NavigationStack {
                SettingsScreen()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            GeoCircleCloseButton { activeSheet = nil }
                        }
                    }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.automatic)
        }
    }
}
