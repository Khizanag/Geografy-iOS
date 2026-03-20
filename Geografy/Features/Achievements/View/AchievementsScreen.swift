import SwiftUI

struct AchievementsScreen: View {
    var body: some View {
        placeholderContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GeoColors.background)
            .navigationTitle("Achievements")
    }
}

// MARK: - Subviews

private extension AchievementsScreen {
    var placeholderContent: some View {
        VStack(spacing: GeoSpacing.md) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundStyle(GeoColors.accent.opacity(0.5))

            Text("Coming Soon")
                .font(GeoFont.title2)
                .foregroundStyle(GeoColors.textSecondary)
        }
    }
}
