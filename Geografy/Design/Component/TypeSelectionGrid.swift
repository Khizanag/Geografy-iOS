import SwiftUI

protocol SelectableType: Identifiable, Hashable {
    var displayName: String { get }
    var icon: String { get }
    var emoji: String { get }
    var description: String { get }
}

struct TypeSelectionGrid<T: SelectableType>: View {
    let items: [T]
    let selectedIDs: Set<T.ID>
    let onSelect: (T) -> Void
    var isLocked: (T) -> Bool = { _ in false }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(items) { item in
                    typeCard(item)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .scrollClipDisabled()
    }
}

// MARK: - Subviews

private extension TypeSelectionGrid {
    func typeCard(_ item: T) -> some View {
        let isSelected = selectedIDs.contains(item.id)
        let locked = isLocked(item)

        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onSelect(item)
        } label: {
            cardContent(item: item, isSelected: isSelected, isLocked: locked)
        }
        .buttonStyle(.plain)
    }

    func cardContent(item: T, isSelected: Bool, isLocked: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack {
                Image(systemName: item.icon)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(
                        isSelected
                            ? DesignSystem.Color.onAccent
                            : DesignSystem.Color.accent
                    )
                Spacer()
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                }
            }

            Spacer(minLength: 0)

            Text(item.displayName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(
                    isSelected
                        ? DesignSystem.Color.onAccent
                        : DesignSystem.Color.textPrimary
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(item.description)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(
                    isSelected
                        ? DesignSystem.Color.onAccent.opacity(0.7)
                        : DesignSystem.Color.textSecondary
                )
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DesignSystem.Spacing.sm)
        .frame(width: 150, height: 130)
        .background(
            isSelected
                ? DesignSystem.Color.accent
                : DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .strokeBorder(
                    isSelected
                        ? DesignSystem.Color.accent.opacity(0.8)
                        : DesignSystem.Color.cardBackgroundHighlighted,
                    lineWidth: 1
                )
        )
        .shadow(
            color: isSelected ? DesignSystem.Color.accent.opacity(0.3) : .clear,
            radius: 12,
            y: 4
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
