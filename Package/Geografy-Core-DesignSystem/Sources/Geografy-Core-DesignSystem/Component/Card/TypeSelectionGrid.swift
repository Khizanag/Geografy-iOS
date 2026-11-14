import Geografy_Core_Common
import SwiftUI

/// A row of selectable type tiles that scrolls sideways: icon, name, and a short description for each.
public struct TypeSelectionGrid<T: SelectableType>: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif

    @ScaledMetric(relativeTo: .subheadline) private var tileWidth: CGFloat = 156

    /// Starts on the first selected tile, so a saved choice further along is never off screen.
    @State private var scrolledID: T.ID?

    public let items: [T]
    public let selectedIDs: Set<T.ID>
    public let color: Color
    public let onSelect: (T) -> Void

    // MARK: - Init
    /// - Parameter color: The screen's game color, used for the icons and the selected tile.
    public init(
        items: [T],
        selectedIDs: Set<T.ID>,
        color: Color,
        onSelect: @escaping (T) -> Void
    ) {
        self.items = items
        self.selectedIDs = selectedIDs
        self.color = color
        self.onSelect = onSelect
    }

    // MARK: - Body
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                ForEach(items) { item in
                    typeTile(item)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, DesignSystem.Spacing.md, for: .scrollContent)
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
            tileContent(item: item, isSelected: isSelected)
        }
        .buttonStyle(PressButtonStyle())
        .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: isSelected)
        .accessibilityLabel(item.displayName)
        .accessibilityValue(item.description)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
