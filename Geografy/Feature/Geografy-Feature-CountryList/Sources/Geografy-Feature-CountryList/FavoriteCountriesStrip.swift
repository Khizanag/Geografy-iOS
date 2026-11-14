import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// The user's favorite countries as a sideways row of flag tiles, so they're one tap away above the full list.
struct FavoriteCountriesStrip: View {
    // MARK: - Properties
    let countries: [Country]
    let onSelect: (Country) -> Void

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: String(localized: "Favorites", bundle: .module), icon: "heart.fill")
            tiles
        }
    }
}

// MARK: - Subviews
private extension FavoriteCountriesStrip {
    var tiles: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(countries) { country in
                    Button { onSelect(country) } label: {
                        CountryFlagTile(country: country)
                    }
                    .buttonStyle(PressButtonStyle())
                    .countryContextMenu(country)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.xxs)
        }
        .scrollClipDisabled()
    }
}
