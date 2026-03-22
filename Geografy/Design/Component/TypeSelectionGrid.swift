import SwiftUI

protocol SelectableType: Identifiable, Hashable {
    var displayName: String { get }
    var icon: String { get }
    var emoji: String { get }
}

struct TypeSelectionGrid<T: SelectableType>: View {
    let items: [T]
    let selectedIDs: Set<T.ID>
    let onSelect: (T) -> Void
    var isLocked: (T) -> Bool = { _ in false }

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: 150),
                    spacing: DesignSystem.Spacing.xs,
                ),
            ],
            spacing: DesignSystem.Spacing.xs
        ) {
            ForEach(items) { item in
                typeChip(item)
            }
        }
    }
}

// MARK: - Subviews

private extension TypeSelectionGrid {
    func typeChip(_ item: T) -> some View {
        let isSelected = selectedIDs.contains(item.id)
        let locked = isLocked(item)

        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onSelect(item)
        } label: {
            chipLabel(item: item, isSelected: isSelected, isLocked: locked)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }

    func chipLabel(item: T, isSelected: Bool, isLocked: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text(item.emoji)
                .font(DesignSystem.Font.title2)

            Text(item.displayName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            if isLocked {
                Image(systemName: "lock.fill")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
        .foregroundStyle(
            isSelected
                ? DesignSystem.Color.onAccent
                : DesignSystem.Color.textPrimary
        )
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            isSelected
                ? DesignSystem.Color.accent
                : DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(
                    isSelected
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.cardBackgroundHighlighted,
                    lineWidth: 1
                )
        )
    }
}
