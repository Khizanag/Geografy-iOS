import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// A continent card: its silhouette, its name and country count, and either a radio-style mark
/// when it's one choice of several, or a chevron when it opens the continent.
public struct ContinentTile: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ScaledMetric(relativeTo: .title) private var outlineHeight: CGFloat = 56

    let continent: Country.Continent
    let outline: ContinentOutline?
    let countryCount: Int
    let color: Color
    let isSelected: Bool?
    let action: () -> Void

    // MARK: - Init
    /// - Parameter isSelected: Whether this continent is the chosen one, for a picker; nil for a tile that opens it.
    public init(
        continent: Country.Continent,
        outline: ContinentOutline?,
        countryCount: Int,
        color: Color,
        isSelected: Bool? = nil,
        action: @escaping () -> Void
    ) {
        self.continent = continent
        self.outline = outline
        self.countryCount = countryCount
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }

    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            tileContent
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel(continent.displayName)
        .accessibilityValue(Text("\(countryCount) countries"))
        .accessibilityAddTraits(isSelected == true ? .isSelected : [])
        .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: isSelected)
    }
}

// MARK: - Subviews
private extension ContinentTile {
    var tileContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            silhouette
                .frame(maxWidth: .infinity)
                .frame(height: outlineHeight)
            titleRow
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .selectableTileBackground(
            isSelected: isSelected ?? false,
            color: color,
            cornerRadius: DesignSystem.CornerRadius.extraLarge
        )
        .contentShape(.rect(cornerRadius: DesignSystem.CornerRadius.extraLarge))
    }

    /// A picker greys out the continents not chosen; a tile that opens one shows it in its color.
    var silhouetteColor: Color {
        guard let isSelected else { return color }
        return isSelected ? color : DesignSystem.Color.textTertiary
    }

    @ViewBuilder
    var silhouette: some View {
        if let outline {
            ContinentOutlineView(outline: outline, fill: silhouetteColor)
        } else {
            Image(systemName: continent.icon)
                .font(DesignSystem.Font.title)
                .foregroundStyle(silhouetteColor)
                .accessibilityHidden(true)
        }
    }

    var titleRow: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.xs) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(continent.displayName)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("\(countryCount) countries")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer(minLength: 0)
            if let isSelected {
                SelectionMark(isSelected: isSelected, color: color)
            } else {
                RowChevron()
            }
        }
    }
}
