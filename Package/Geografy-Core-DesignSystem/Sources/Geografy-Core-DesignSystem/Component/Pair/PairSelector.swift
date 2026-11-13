import SwiftUI

/// Two slots side by side with a glass control between them: the header of every "pick two" screen.
/// The control reads "VS" (or a custom label) until both are picked, then swaps them.
public struct PairSelector: View {
    // MARK: - Properties
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let left: PairSlotItem?
    private let right: PairSlotItem?
    private let roles: (left: String, right: String)
    private let placeholder: String
    private let centerLabel: String
    private let onPick: (PairSide) -> Void
    private let onClear: (PairSide) -> Void
    private let onSwap: () -> Void

    // MARK: - Init
    public init(
        left: PairSlotItem?,
        right: PairSlotItem?,
        roles: (left: String, right: String),
        placeholder: String,
        centerLabel: String = "VS",
        onPick: @escaping (PairSide) -> Void,
        onClear: @escaping (PairSide) -> Void,
        onSwap: @escaping () -> Void
    ) {
        self.left = left
        self.right = right
        self.roles = roles
        self.placeholder = placeholder
        self.centerLabel = centerLabel
        self.onPick = onPick
        self.onClear = onClear
        self.onSwap = onSwap
    }

    // MARK: - Body
    public var body: some View {
        let layout = isStacked
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.xs))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.xs))
        layout {
            slot(.left)
            centerControl
            slot(.right)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Subviews
private extension PairSelector {
    var isStacked: Bool { dynamicTypeSize.isAccessibilitySize }

    func slot(_ side: PairSide) -> some View {
        PairSlot(
            item: side == .left ? left : right,
            side: side,
            role: side == .left ? roles.left : roles.right,
            placeholder: placeholder,
            onPick: { onPick(side) },
            onClear: { onClear(side) }
        )
    }

    @ViewBuilder
    var centerControl: some View {
        if left != nil, right != nil {
            Button(action: onSwap) {
                Image(systemName: isStacked ? "arrow.up.arrow.down" : "arrow.left.arrow.right")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
                    .glassEffect(.regular.interactive(), in: .circle)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Swap")
        } else {
            Text(centerLabel)
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
                .glassEffect(.regular, in: .circle)
                .accessibilityHidden(true)
        }
    }
}
