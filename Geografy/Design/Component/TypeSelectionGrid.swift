import SwiftUI

struct TypeSelectionGrid<T: SelectableType>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(HapticsService.self) private var hapticsService

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
            hapticsService.impact(.light)
            onSelect(item)
        } label: {
            cardContent(item: item, isSelected: isSelected, isLocked: locked)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(item.displayName), \(item.description)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHint(locked ? "Premium feature, locked" : "Double tap to select")
    }

    func cardContent(item: T, isSelected: Bool, isLocked: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                                ? DesignSystem.Color.onAccent.opacity(0.20)
                                : DesignSystem.Color.accent.opacity(0.15)
                        )
                        .frame(width: 36, height: 36)
                    Image(systemName: item.icon)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(
                            isSelected
                                ? DesignSystem.Color.onAccent
                                : DesignSystem.Color.accent
                        )
                }
                Spacer()
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(
                            isSelected
                                ? DesignSystem.Color.onAccent.opacity(0.6)
                                : DesignSystem.Color.textTertiary
                        )
                        .padding(6)
                        .background(
                            isSelected
                                ? DesignSystem.Color.onAccent.opacity(0.12)
                                : DesignSystem.Color.cardBackgroundHighlighted,
                            in: Circle()
                        )
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            Spacer(minLength: 0)

            Text(item.emoji)
                .font(DesignSystem.Font.iconDefault)

            Text(item.displayName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.bold)
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
                        ? DesignSystem.Color.onAccent.opacity(0.75)
                        : DesignSystem.Color.textSecondary
                )
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DesignSystem.Spacing.sm)
        .frame(width: 158, height: 148)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .fill(
                        LinearGradient(
                            colors: [DesignSystem.Color.accent, DesignSystem.Color.accentDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .fill(reduceTransparency ? AnyShapeStyle(DesignSystem.Color.cardBackground) : AnyShapeStyle(.ultraThinMaterial))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                            .fill(DesignSystem.Color.cardBackground.opacity(0.6))
                    )
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .strokeBorder(
                    isSelected
                        ? DesignSystem.Color.accent.opacity(0.5)
                        : .white.opacity(0.07),
                    lineWidth: 1
                )
        )
        .shadow(
            color: isSelected ? DesignSystem.Color.accent.opacity(0.40) : .black.opacity(0.12),
            radius: isSelected ? 16 : 4,
            y: isSelected ? 6 : 2
        )
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
