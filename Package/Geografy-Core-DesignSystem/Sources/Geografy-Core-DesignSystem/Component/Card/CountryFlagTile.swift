import Geografy_Core_Common
import SwiftUI

/// A flag over a country name, the same size for every country so rows of tiles line up.
public struct CountryFlagTile: View {
    // MARK: - Properties
    private let country: Country
    private let isHighlighted: Bool
    private let flagHeight: CGFloat = 36
    // FlagView's fixed-width slot, so tiles keep the size they had with fixedWidth.
    private let flagSlotWidth: CGFloat = 36 * 1.6

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

    // The flag is sized to fit the slot here, so its outline hugs the flag rather than the slot.
    @ViewBuilder
    private var flag: some View {
        if let ratio = FlagAspectRatio.ratio(for: country.code) {
            FlagView(countryCode: country.code, height: min(flagHeight, flagSlotWidth / ratio), isOutlined: true)
                .frame(width: flagSlotWidth, height: flagHeight)
        } else {
            FlagView(countryCode: country.code, height: flagHeight, fixedWidth: true, isOutlined: true)
        }
    }

    private var tile: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.xs) {
                flag
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
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                .strokeBorder(
                    isHighlighted ? DesignSystem.Color.accent.opacity(DesignSystem.Opacity.half) : .clear,
                    lineWidth: 1.5
                )
        }
    }
}
