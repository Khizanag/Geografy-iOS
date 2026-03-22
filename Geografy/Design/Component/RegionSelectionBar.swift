import SwiftUI

protocol RegionSelectable: Identifiable, Hashable {
    var displayName: String { get }
    var regionIcon: String { get }
}

struct RegionSelectionBar<T: RegionSelectable>: View {
    let items: [T]
    let selectedID: T.ID
    let onSelect: (T) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(items) { item in
                    regionChip(item)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews

private extension RegionSelectionBar {
    func regionChip(_ item: T) -> some View {
        let isSelected = selectedID == item.id

        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onSelect(item)
        } label: {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: item.regionIcon)
                    .font(DesignSystem.Font.caption)
                Text(item.displayName)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundStyle(
                isSelected
                    ? DesignSystem.Color.onAccent
                    : DesignSystem.Color.textSecondary
            )
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                isSelected
                    ? DesignSystem.Color.accent
                    : DesignSystem.Color.cardBackground,
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.cardBackgroundHighlighted,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
