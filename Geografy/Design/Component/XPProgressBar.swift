import SwiftUI

struct XPProgressBar: View {
    let currentLevelNumber: Int
    let nextLevelNumber: Int?
    let xpInCurrentLevel: Int
    let xpRequiredForNextLevel: Int
    let progressFraction: Double

    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            levelLabelsRow
            progressTrack
            xpCountLabel
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.15)) {
                animatedProgress = progressFraction
            }
        }
        .onChange(of: progressFraction) { _, newValue in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Subviews

private extension XPProgressBar {
    var levelLabelsRow: some View {
        HStack {
            Text("Lv. \(currentLevelNumber)")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer()
            if let next = nextLevelNumber {
                Text("Lv. \(next)")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            } else {
                Text("MAX")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        }
    }

    var progressTrack: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill)
                    .fill(DesignSystem.Color.cardBackgroundHighlighted)
                    .frame(height: DesignSystem.Spacing.xs)
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill)
                    .fill(progressGradient)
                    .frame(width: geometry.size.width * animatedProgress, height: 8)
            }
        }
        .frame(height: DesignSystem.Spacing.xs)
    }

    var xpCountLabel: some View {
        HStack {
            Spacer()
            Text("\(xpInCurrentLevel) / \(xpRequiredForNextLevel) XP")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var progressGradient: LinearGradient {
        LinearGradient(
            colors: [DesignSystem.Color.accent, DesignSystem.Color.accentDark],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
