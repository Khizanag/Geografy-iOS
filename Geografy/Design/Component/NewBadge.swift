import GeografyDesign
import SwiftUI

struct NewBadge: View {
    var body: some View {
        Text("NEW")
            .font(DesignSystem.Font.caption2)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.xs)
            .padding(.vertical, 2)
            .background(DesignSystem.Color.accent, in: Capsule())
        .accessibilityLabel("New")
    }
}
