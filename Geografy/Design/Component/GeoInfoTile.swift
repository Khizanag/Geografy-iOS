import SwiftUI

struct GeoInfoTile: View {
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
        GeoCard {
            tileContent
                .padding(GeoSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Subviews

private extension GeoInfoTile {
    var tileContent: some View {
        VStack(alignment: .leading, spacing: GeoSpacing.xs) {
            Image(systemName: icon)
                .font(GeoFont.headline)
                .foregroundStyle(GeoColors.accent)

            Text(title)
                .font(GeoFont.caption)
                .foregroundStyle(GeoColors.textSecondary)

            Text(value)
                .font(GeoFont.headline)
                .foregroundStyle(GeoColors.textPrimary)
        }
    }
}
