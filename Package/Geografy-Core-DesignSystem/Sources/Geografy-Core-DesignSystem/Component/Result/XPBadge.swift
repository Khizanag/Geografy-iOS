import SwiftUI

/// XP earned, the same under every result: a gold star and the amount in a capsule.
public struct XPBadge: View {
    // MARK: - Properties
    private let xp: Int

    // MARK: - Init
    public init(xp: Int) {
        self.xp = xp
    }

    // MARK: - Body
    public var body: some View {
        Label {
            Text("+\(xp) XP")
        } icon: {
            Image(systemName: "star.fill")
        }
        .font(DesignSystem.Font.headline)
        .fontWeight(.bold)
        .foregroundStyle(DesignSystem.Color.warning)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(DesignSystem.Color.warning.opacity(DesignSystem.Opacity.tint), in: .capsule)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(xp) XP earned"))
    }
}
