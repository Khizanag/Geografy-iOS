import SwiftUI

/// A horizontally scrollable chain of country cards showing the border-hop path.
struct NeighborChainView: View {
    let chain: [Country]
    let onSelectCountry: (Country) -> Void

    var body: some View {
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
            CardView(cornerRadius: DesignSystem.CornerRadius.large) {
                VStack(spacing: DesignSystem.Spacing.xs) {
                    FlagView(countryCode: country.code, height: 36)
                        .geoShadow(.subtle)
                    Text(country.name)
                        .font(DesignSystem.Font.caption2)
                        .fontWeight(isFirst ? .bold : .semibold)
                        .foregroundStyle(
                            isFirst ? DesignSystem.Color.accent : DesignSystem.Color.textPrimary
                        )
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(width: 68)
                }
                .padding(.horizontal, DesignSystem.Spacing.xs)
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .strokeBorder(
                        isFirst ? DesignSystem.Color.accent.opacity(0.5) : .clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(PressButtonStyle())
    }
}
