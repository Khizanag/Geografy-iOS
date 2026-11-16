import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// A horizontally scrollable chain of country cards showing the border-hop path.
public struct NeighborChainView: View {
    // MARK: - Properties
    public let chain: [Country]
    public let onSelectCountry: (Country) -> Void

    // MARK: - Body
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(Array(chain.enumerated()), id: \.element.id) { index, country in
                    chainItem(country: country, index: index)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .scrollClipDisabled()
    }
}

// MARK: - Subviews
private extension NeighborChainView {
    func chainItem(country: Country, index: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            if index > 0 {
                arrowConnector
            }
            countryCard(country: country, isFirst: index == 0)
        }
    }

    var arrowConnector: some View {
        Image(systemName: "arrow.right")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textTertiary)
    }

    func countryCard(country: Country, isFirst: Bool) -> some View {
        Button {
            onSelectCountry(country)
        } label: {
            CountryFlagTile(country: country, isHighlighted: isFirst)
        }
        .buttonStyle(PressButtonStyle())
    }
}
