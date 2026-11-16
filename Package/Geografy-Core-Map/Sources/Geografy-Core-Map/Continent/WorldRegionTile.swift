import Geografy_Core_DesignSystem
import SwiftUI

/// The "whole world" choice of a region picker: the world map, its country count, and a radio-style mark.
/// Sits above a grid of `ContinentTile`s.
public struct WorldRegionTile: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ScaledMetric(relativeTo: .title) private var thumbnailHeight: CGFloat = 56

    let countryCount: Int
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    // MARK: - Init
    /// - Parameter color: The screen's game color, used for the selected tile.
    public init(countryCount: Int, color: Color, isSelected: Bool, action: @escaping () -> Void) {
        self.countryCount = countryCount
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }

    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.md) {
                WorldMapThumbnail()
                    .frame(width: thumbnailHeight * 1.7, height: thumbnailHeight)
                    .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.small))
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Whole World", bundle: .module)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("\(countryCount) countries", bundle: .module)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer(minLength: 0)
                SelectionMark(isSelected: isSelected, color: color)
            }
            .padding(DesignSystem.Spacing.md)
            .selectableTileBackground(isSelected: isSelected, color: color)
            .contentShape(.rect(cornerRadius: DesignSystem.CornerRadius.extraLarge))
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: isSelected)
    }
}
