import SwiftUI

public struct ResultStatItem: View {
    public let icon: String
    public let value: String
    public let label: String
    public var color: Color = DesignSystem.Color.accent

    public init(
        icon: String,
        value: String,
        label: String,
        color: Color = DesignSystem.Color.accent
    ) {
        self.icon = icon
        self.value = value
        self.label = label
        self.color = color
    }

    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(color)
            Text(value)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
