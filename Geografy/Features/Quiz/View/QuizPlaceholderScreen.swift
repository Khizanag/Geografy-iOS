import SwiftUI

struct QuizPlaceholderScreen: View {
    var body: some View {
        placeholderContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GeoColors.background)
            .navigationTitle("Quiz")
    }
}

// MARK: - Subviews

private extension QuizPlaceholderScreen {
    var placeholderContent: some View {
        VStack(spacing: GeoSpacing.md) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(GeoColors.accent.opacity(0.5))

            Text("Coming Soon")
                .font(GeoFont.title2)
                .foregroundStyle(GeoColors.textSecondary)
        }
    }
}
