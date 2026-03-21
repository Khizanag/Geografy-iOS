import SwiftUI

struct PremiumLockedOverlay: View {
    let onUnlock: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("Premium Feature")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Button(action: onUnlock) {
                    Text("Unlock with Premium")
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(DesignSystem.Color.accent, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}
