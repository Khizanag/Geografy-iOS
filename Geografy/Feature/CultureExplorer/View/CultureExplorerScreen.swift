import SwiftUI

struct CultureExplorerScreen: View {
    @State private var searchQuery = ""
    @State private var selectedProfile: CultureProfile?

    private let service = CultureProfileService()

    private var filteredProfiles: [CultureProfile] {
        service.profiles(matching: searchQuery)
    }

    private var countryName: (String) -> String {
        { code in Locale.current.localizedString(forRegionCode: code) ?? code }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                searchBar
                profileList
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Culture Explorer")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedProfile) { profile in
            NavigationStack {
                CultureDetailView(profile: profile)
            }
            .presentationDetents([.large])
        }
    }
}

// MARK: - Subviews
private extension CultureExplorerScreen {
    var searchBar: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DesignSystem.Color.textSecondary)
            TextField("Search countries or dishes...", text: $searchQuery)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    var profileList: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(filteredProfiles) { profile in
                profileRow(profile)
            }
        }
    }

    func profileRow(_ profile: CultureProfile) -> some View {
        Button {
            selectedProfile = profile
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.md) {
                    FlagView(countryCode: profile.countryCode, height: 36)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    rowInfo(profile)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    func rowInfo(_ profile: CultureProfile) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(countryName(profile.countryCode))
                .font(DesignSystem.Font.headline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Famous for: \(profile.famousFor.prefix(3).joined(separator: ", "))")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
    }
}
