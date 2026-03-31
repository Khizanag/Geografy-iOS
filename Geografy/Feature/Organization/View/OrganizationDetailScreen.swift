import SwiftUI
import GeografyDesign
import GeografyCore

struct OrganizationDetailScreen: View {
    @Environment(Navigator.self) private var coordinator
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(AchievementService.self) private var achievementService
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let organization: Organization

    @State private var showLogoZoom = false
    @State private var blobAnimating = false

    var body: some View {
        ZStack {
            ambientBackground
            scrollContent
        }
        .navigationTitle(organization.displayName)
        .closeButtonPlacementLeading()
        .background(DesignSystem.Color.background)
        .overlay {
            if showLogoZoom, let urlString = organization.logoURL, let url = URL(string: urlString) {
                ZoomableOrgLogoView(url: url, organization: organization) {
                    showLogoZoom = false
                }
            }
        }
        .task { trackOrgView() }
        .onAppear { blobAnimating = true }
    }
}

// MARK: - Background
private extension OrganizationDetailScreen {
    var ambientBackground: some View {
        ZStack {
            DesignSystem.Color.background

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [organization.highlightColor.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 360, height: 280)
                .blur(radius: 30)
                .offset(x: -60, y: -180)
                .scaleEffect(blobAnimating ? 1.08 : 0.94)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.indigo.opacity(0.10), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 300, height: 260)
                .blur(radius: 40)
                .offset(x: 120, y: 260)
                .scaleEffect(blobAnimating ? 0.92 : 1.06)
        }
        .ignoresSafeArea()
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 5).repeatForever(autoreverses: true),
            value: blobAnimating
        )
    }
}

// MARK: - Content
private extension OrganizationDetailScreen {
    var scrollContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                headerCard
                openMapButton
                memberCountriesSection
            }
            .padding(DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }

    var headerCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    orgLogo
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(organization.displayName)
                            .font(DesignSystem.Font.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        if organization.fullName != organization.displayName {
                            Text(organization.fullName)
                                .font(DesignSystem.Font.caption)
                                .foregroundStyle(DesignSystem.Color.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Text("\(memberCountries.count) member countries")
                            .font(DesignSystem.Font.caption2)
                            .foregroundStyle(organization.highlightColor)
                            .padding(.horizontal, DesignSystem.Spacing.xs)
                            .padding(.vertical, 3)
                            .background(organization.highlightColor.opacity(0.12), in: Capsule())
                            .accessibilityLabel("\(memberCountries.count) member countries")
                    }
                    Spacer(minLength: 0)
                }

                Divider()

                Text(organization.description)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var orgLogo: some View {
        Group {
            if let urlString = organization.logoURL, let url = URL(string: urlString) {
                Button {
                    showLogoZoom = true
                } label: {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: DesignSystem.Size.xxxl, height: DesignSystem.Size.xxxl)
                        default:
                            orgLogoFallback
                        }
                    }
                }
                .buttonStyle(.plain)
            } else {
                orgLogoFallback
            }
        }
    }

    var orgLogoFallback: some View {
        ZStack {
            Circle()
                .fill(organization.highlightColor.opacity(0.15))
                .frame(width: DesignSystem.Size.xxxl, height: DesignSystem.Size.xxxl)
            Image(systemName: organization.icon)
                .font(DesignSystem.IconSize.large)
                .foregroundStyle(organization.highlightColor)
        }
    }

    var openMapButton: some View {
        Button {
            hapticsService.impact(.medium)
            coordinator.cover(.map(continentFilter: nil))
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "map.fill")
                    .font(DesignSystem.Font.headline)
                Text("Open Map")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "arrow.right")
                    .font(DesignSystem.Font.headline)
            }
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(DesignSystem.Spacing.md)
            .background(
                LinearGradient(
                    colors: [organization.highlightColor, organization.highlightColor.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
            .shadow(color: organization.highlightColor.opacity(0.4), radius: 10, y: 4)
        }
        .buttonStyle(PressButtonStyle())
    }

    var memberCountriesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text("Member Countries")
                .font(DesignSystem.Font.title2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.xxs)
                .accessibilityAddTraits(.isHeader)

            ForEach(memberCountries) { country in
                Button { coordinator.push(.countryDetail(country)) } label: {
                    CardView {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            FlagView(countryCode: country.code, height: DesignSystem.Size.md)
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                                Text(country.name)
                                    .font(DesignSystem.Font.headline)
                                    .foregroundStyle(DesignSystem.Color.textPrimary)
                                    .lineLimit(1)
                                Text(country.capital)
                                    .font(DesignSystem.Font.caption)
                                    .foregroundStyle(DesignSystem.Color.textSecondary)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 0)
                            if favoritesService.isFavorite(code: country.code) {
                                Image(systemName: "heart.fill")
                                    .font(DesignSystem.Font.caption2)
                                    .foregroundStyle(DesignSystem.Color.error)
                                    .accessibilityLabel("Favorite")
                            }
                            Image(systemName: "chevron.right")
                                .font(DesignSystem.Font.caption2)
                                .foregroundStyle(DesignSystem.Color.textTertiary)
                                .accessibilityHidden(true)
                        }
                        .padding(DesignSystem.Spacing.sm)
                    }
                }
                .buttonStyle(PressButtonStyle())
                .simultaneousGesture(TapGesture().onEnded {
                    hapticsService.impact(.light)
                })
            }
        }
    }
}

// MARK: - Gamification
private extension OrganizationDetailScreen {
    func trackOrgView() {
        let key = "viewed_orgs_\(achievementService.currentUserID)"
        var viewed = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        viewed.insert(organization.id)
        UserDefaults.standard.set(Array(viewed), forKey: key)
        achievementService.checkKnowledgeAchievements(orgsOpened: viewed.count)
    }
}

// MARK: - Helpers
private extension OrganizationDetailScreen {
    var memberCountries: [Country] {
        countryDataService.countries
            .filter { $0.organizations.contains(organization.id) }
            .sorted { $0.name < $1.name }
    }
}
