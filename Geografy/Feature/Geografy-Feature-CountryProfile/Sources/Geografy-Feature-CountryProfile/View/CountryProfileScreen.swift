import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public struct CountryProfileScreen: View {
    // MARK: - Properties
    public let country: Country
    public let profile: CountryProfile?

    // MARK: - Init
    public init(country: Country, profile: CountryProfile?) {
        self.country = country
        self.profile = profile
    }

    // MARK: - Body
    public var body: some View {
        mainContent
            .background(DesignSystem.Color.background)
            .navigationTitle("Deep Dive")
    }
}

// MARK: - Main Content
private extension CountryProfileScreen {
    @ViewBuilder
    var mainContent: some View {
        if let profile {
            profileContent(profile)
        } else {
            comingSoonPlaceholder
        }
    }
}

// MARK: - Profile Content
private extension CountryProfileScreen {
    func profileContent(_ profile: CountryProfile) -> some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                heroHeader
                CountryProfileSection(profile: profile)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }
}

// MARK: - Hero Header
private extension CountryProfileScreen {
    var heroHeader: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            FlagView(
                countryCode: country.code,
                height: DesignSystem.Size.xxl
            )
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(country.name)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(country.continent.displayName)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Coming Soon
private extension CountryProfileScreen {
    var comingSoonPlaceholder: some View {
        ComingSoonView(
            icon: "book.pages",
            title: "Deep Dive"
        )
    }
}
