import SwiftUI

struct ComingSoonView: View {
    let icon: String

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: GeoSpacing.xl) {
            Spacer()
            iconSection
            textSection
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GeoColors.background)
        .onAppear { isAnimating = true }
    }
}

// MARK: - Subviews

private extension ComingSoonView {
    var iconSection: some View {
        ZStack {
            Circle()
                .fill(GeoColors.accent.opacity(0.08))
                .frame(width: 140, height: 140)

            Circle()
                .fill(GeoColors.accent.opacity(0.05))
                .frame(width: 200, height: 200)

            Image(systemName: icon)
                .font(GeoIconSize.xxLarge)
                .foregroundStyle(GeoColors.accent)
                .symbolEffect(.pulse, options: .repeating, isActive: isAnimating)
        }
    }

    var textSection: some View {
        VStack(spacing: GeoSpacing.xs) {
            Text("Coming Soon")
                .font(GeoFont.title2)
                .foregroundStyle(GeoColors.textPrimary)

            Text("We're working on something great.")
                .font(GeoFont.subheadline)
                .foregroundStyle(GeoColors.textSecondary)
        }
    }
}
