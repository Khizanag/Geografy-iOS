import SwiftUI

struct InfoTile: View {
    private let icon: String
    private let title: String
    private let value: String
    private let onTap: () -> Void

    init(
        icon: String,
        title: String,
        value: String,
        onTap: @escaping () -> Void = {}
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.onTap = onTap
    }

    var body: some View {
        CardView {
            tileContent
                .padding(DesignSystem.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Subviews
private extension InfoTile {
    var tileContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent)

            Text(title)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)

            Text(value)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }
}
