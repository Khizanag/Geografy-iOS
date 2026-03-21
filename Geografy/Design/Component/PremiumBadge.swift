import SwiftUI

struct PremiumBadge: View {
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "crown.fill")
                .font(DesignSystem.Font.caption2)
            Text("Premium")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(DesignSystem.Color.warning)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(DesignSystem.Color.warning.opacity(0.15), in: Capsule())
    }
}
