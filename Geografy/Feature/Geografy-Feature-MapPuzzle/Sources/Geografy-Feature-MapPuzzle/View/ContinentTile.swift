import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// A selectable region card: the continent's silhouette, its name and country count, and a radio-style mark.
struct ContinentTile: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ScaledMetric(relativeTo: .title) private var outlineHeight: CGFloat = 72

    let continent: Country.Continent
    let outline: ContinentOutline?
    let countryCount: Int
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    // MARK: - Body
    var body: some View {
        Button(action: action) {
            tileContent
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel(continent.displayName)
        .accessibilityValue("\(countryCount) countries")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: isSelected)
    }
}

// MARK: - Subviews
private extension ContinentTile {
    var tileContent: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                silhouette
                    .frame(maxWidth: .infinity)
                    .frame(height: outlineHeight)
                titleRow
            }
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if isSelected {
                    color.opacity(0.12)
                }
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge, style: .continuous)
                .strokeBorder(isSelected ? color : .clear, lineWidth: 2)
        }
        .contentShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge, style: .continuous))
    }

    @ViewBuilder
    var silhouette: some View {
        if let outline {
            ContinentOutlineView(
                outline: outline,
                fill: isSelected ? color : DesignSystem.Color.mapLandMuted
            )
        } else {
            Image(systemName: continent.icon)
                .font(DesignSystem.Font.title)
                .foregroundStyle(isSelected ? color : DesignSystem.Color.textTertiary)
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
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(DesignSystem.Font.title3)
                .foregroundStyle(isSelected ? color : DesignSystem.Color.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
