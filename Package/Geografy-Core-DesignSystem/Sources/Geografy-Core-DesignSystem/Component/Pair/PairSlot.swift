import SwiftUI

/// One side of a pair: the picked item outlined in its side's color, or a dashed slot inviting a pick.
struct PairSlot: View {
    // MARK: - Properties
    let item: PairSlotItem?
    let side: PairSide
    let role: String
    let placeholder: String
    let onPick: () -> Void
    let onClear: () -> Void

    // MARK: - Body
    var body: some View {
        Button(action: onPick) {
            slotContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background { slotBackground }
                .contentShape(.contextMenuPreview, Self.shape)
                .contentShape(Self.shape)
        }
        .buttonStyle(PressButtonStyle())
        .contextMenu {
            if item != nil {
                Button("Change", systemImage: "arrow.triangle.2.circlepath", action: onPick)
                Button("Remove", systemImage: "xmark", role: .destructive, action: onClear)
            }
        }
        .accessibilityLabel("\(role): \(item?.title ?? "not chosen")")
        .accessibilityHint(item == nil ? "Chooses one" : "Changes it")
        .accessibilityActions {
            if item != nil {
                Button("Remove", action: onClear)
            }
        }
    }
}

// MARK: - Subviews
private extension PairSlot {
    static let shape = RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge, style: .continuous)

    @ViewBuilder
    var slotContent: some View {
        if let item {
            filledContent(item)
        } else {
            emptyContent
        }
    }

    func filledContent(_ item: PairSlotItem) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            FlagView(countryCode: item.flagCode, height: DesignSystem.Size.Flag.compact)
                .geoShadow(.subtle)
                .padding(.bottom, DesignSystem.Spacing.xxs)
                .accessibilityHidden(true)

            Text(item.title)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            if let subtitle = item.subtitle {
                Text(subtitle)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
    }

    var emptyContent: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "plus")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(side.color)
                .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
                .background(side.color.opacity(0.15), in: Circle())
                .accessibilityHidden(true)

            Text(placeholder)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    var slotBackground: some View {
        if item != nil {
            Self.shape
                .fill(DesignSystem.Color.cardBackground)
                .overlay {
                    Self.shape.strokeBorder(side.color.opacity(0.6), lineWidth: 1.5)
                }
        } else {
            Self.shape
                .fill(side.color.opacity(0.06))
                .overlay {
                    Self.shape.strokeBorder(
                        side.color.opacity(0.5),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 5])
                    )
                }
        }
    }
}
