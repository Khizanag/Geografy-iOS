import Geografy_Core_Common
import SwiftUI

/// A flag over a country name, the same size for every country so rows of tiles line up.
public struct CountryFlagTile: View {
    // MARK: - Properties
    private let country: Country
    private let isHighlighted: Bool

    // MARK: - Init
    public init(country: Country, isHighlighted: Bool = false) {
        self.country = country
        self.isHighlighted = isHighlighted
    }

    // MARK: - Body
    public var body: some View {
        tile
            .accessibilityElement(children: .combine)
    }

    private var tile: some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.large) {
            VStack(spacing: DesignSystem.Spacing.xs) {
                FlagView(countryCode: country.code, height: 36, fixedWidth: true)
                    .geoShadow(.subtle)
                Text(country.name)
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(isHighlighted ? .bold : .semibold)
                    .foregroundStyle(isHighlighted ? DesignSystem.Color.accent : DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    // Room for two lines, so one-line and two-line names make the same height.
                    .lineLimit(2, reservesSpace: true)
                    .frame(width: 72)
            }
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .overlay {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .strokeBorder(isHighlighted ? DesignSystem.Color.accent.opacity(0.5) : .clear, lineWidth: 1.5)
        }
    }
}
