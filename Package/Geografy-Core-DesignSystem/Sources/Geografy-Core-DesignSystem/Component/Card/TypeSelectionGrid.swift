import Geografy_Core_Common
import SwiftUI

/// Selectable type tiles. As a carousel, a row that scrolls sideways with each type's icon, name, and a short
/// description; as a grid, compact icon-and-name tiles that show every type at once.
public struct TypeSelectionGrid<T: SelectableType>: View {
    public enum Layout: Sendable {
        case carousel
        case grid
    }

    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif

    @ScaledMetric(relativeTo: .subheadline) private var tileWidth: CGFloat = 156
    /// Room for a two-line name, so every compact tile in the grid is the same height.
    @ScaledMetric(relativeTo: .subheadline) private var compactTileHeight: CGFloat = 60

    /// Starts on the first selected tile, so a saved choice further along is never off screen.
    @State private var scrolledID: T.ID?

    public let items: [T]
    public let selectedIDs: Set<T.ID>
    public let color: Color
    public let layout: Layout
    public let onSelect: (T) -> Void

    // MARK: - Init
    /// - Parameters:
    ///   - color: The screen's game color, used for the icons and the selected tile.
    ///   - layout: A grid when every type should show at once, so none hides past the screen's edge.
    public init(
        items: [T],
        selectedIDs: Set<T.ID>,
        color: Color,
        layout: Layout = .carousel,
        onSelect: @escaping (T) -> Void
    ) {
        self.items = items
        self.selectedIDs = selectedIDs
        self.color = color
        self.layout = layout
        self.onSelect = onSelect
    }

    // MARK: - Body
    public var body: some View {
        switch layout {
        case .carousel: carousel
        case .grid: grid
        }
    }
}

// MARK: - Layouts
private extension TypeSelectionGrid {
    var grid: some View {
        LazyVGrid(columns: gridColumns, spacing: DesignSystem.Spacing.sm) {
            ForEach(items) { item in
                typeTile(item)
            }
        }
    }

    var gridColumns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: DesignSystem.Spacing.sm), count: count)
    }

    var carousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                ForEach(items) { item in
                    typeTile(item)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrolledID, anchor: .center)
        .scrollClipDisabled()
        .task { scrolledID = items.first { selectedIDs.contains($0.id) }?.id }
    }
}

// MARK: - Subviews
private extension TypeSelectionGrid {
    func typeTile(_ item: T) -> some View {
        let isSelected = selectedIDs.contains(item.id)
        return Button {
            #if !os(tvOS)
            hapticsService.selection()
            #endif
            onSelect(item)
        } label: {
            switch layout {
            case .carousel: tileContent(item: item, isSelected: isSelected)
            case .grid: compactTileContent(item: item, isSelected: isSelected)
            }
        }
        .buttonStyle(PressButtonStyle())
        .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: isSelected)
        .accessibilityLabel(item.displayName)
        .accessibilityValue(item.description)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// The icon and name side by side; the tile's tint and border mark the chosen one.
    func compactTileContent(item: T, isSelected: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            IconBadge(item.icon, color: color, size: .small)
            Text(item.displayName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .frame(maxWidth: .infinity, minHeight: compactTileHeight, maxHeight: .infinity, alignment: .leading)
        .selectableTileBackground(isSelected: isSelected, color: color)
        .contentShape(.rect(cornerRadius: DesignSystem.CornerRadius.extraLarge))
    }

    func tileContent(item: T, isSelected: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack(alignment: .top) {
                IconBadge(item.icon, color: color, size: .small)
                Spacer(minLength: DesignSystem.Spacing.xs)
                SelectionMark(isSelected: isSelected, color: color)
            }
            Text(item.displayName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
                .minimumScaleFactor(0.85)
            Text(item.description)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DesignSystem.Spacing.sm)
        .frame(width: tileWidth, alignment: .topLeading)
        .frame(maxHeight: .infinity, alignment: .top)
        .selectableTileBackground(isSelected: isSelected, color: color)
    }
}
