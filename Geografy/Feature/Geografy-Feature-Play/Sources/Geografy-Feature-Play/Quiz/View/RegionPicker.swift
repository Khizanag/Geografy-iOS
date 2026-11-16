import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// Picks the region a game draws its countries from: World across the top, the continents two to a row below.
public struct RegionPicker: View {
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryDataService
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding private var selectedRegion: QuizRegion
    private let color: Color

    // MARK: - Init
    /// - Parameter color: The screen's game color, used for the icons and the selected region.
    public init(selectedRegion: Binding<QuizRegion>, color: Color) {
        _selectedRegion = selectedRegion
        self.color = color
    }

    // MARK: - Body
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            regionTile(.world)
            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
                ForEach(QuizRegion.allCases.filter { $0 != .world }) { region in
                    regionTile(region)
                }
            }
        }
    }
}

// MARK: - Subviews
private extension RegionPicker {
    func regionTile(_ region: QuizRegion) -> some View {
        let isSelected = region == selectedRegion
        let countryCount = region.filter(countryDataService.countries).count
        return Button {
            select(region)
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(region.displayName)
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(countryCount) countries", bundle: .module)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
                }
                Spacer(minLength: 0)
                SelectionMark(isSelected: isSelected, color: color)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .selectableTileBackground(isSelected: isSelected, color: color)
        }
        .buttonStyle(PressButtonStyle())
        .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: isSelected)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Helpers
private extension RegionPicker {
    var columns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: DesignSystem.Spacing.sm), count: count)
    }

    func select(_ region: QuizRegion) {
        guard region != selectedRegion else { return }
        #if !os(tvOS)
        hapticsService.selection()
        #endif
        selectedRegion = region
    }
}
