import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// The picture beside a search result: the country's flag, or the organization's symbol in the same slot.
struct SearchRowSymbol: View {
    enum Size {
        case chip
        case row
        case hero

        var height: CGFloat {
            switch self {
            case .chip: 18
            case .row: DesignSystem.Size.Flag.inline
            case .hero: DesignSystem.Size.Flag.compact
            }
        }

        /// Matches `FlagView`'s fixed-width slot, so flags and symbols line up in a list.
        var width: CGFloat { height * 1.6 }
    }

    // MARK: - Properties
    let row: SearchRow
    let size: Size

    // MARK: - Body
    var body: some View {
        symbol
            .accessibilityHidden(true)
    }
}

// MARK: - Subviews
private extension SearchRowSymbol {
    @ViewBuilder
    var symbol: some View {
        switch row {
        case .country(let country), .capital(let country, _):
            FlagView(countryCode: country.code, height: size.height, fixedWidth: true)
                .geoShadow(.subtle)
        case .organization(let organization):
            Image(systemName: organization.icon)
                .font(DesignSystem.Font.system(size: size.height * 0.6, weight: .semibold))
                .foregroundStyle(organization.highlightColor)
                .frame(width: size.width, height: size.height)
                .background(
                    organization.highlightColor.opacity(0.15),
                    in: RoundedRectangle(cornerRadius: size.height * 0.22, style: .continuous)
                )
        }
    }
}
