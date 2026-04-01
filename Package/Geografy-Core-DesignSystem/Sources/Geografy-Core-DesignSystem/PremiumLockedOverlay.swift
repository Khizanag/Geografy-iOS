import SwiftUI

public struct PremiumLockedOverlay: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    public let onUnlock: () -> Void

    public init(onUnlock: @escaping () -> Void) {
        self.onUnlock = onUnlock
    }

    public var body: some View {
        ZStack {
            Rectangle()
                .fill(reduceTransparency ? AnyShapeStyle(DesignSystem.Color.cardBackground) : AnyShapeStyle(.ultraThinMaterial))
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "lock.fill")
                    .font(DesignSystem.Font.title)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("Premium Feature")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Button(action: onUnlock) {
                    Text("Unlock with Premium")
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(DesignSystem.Color.accent, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Premium feature, locked")
        .accessibilityHint("Double tap to unlock with Premium")
    }
}
