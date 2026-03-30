import SwiftUI

struct ScoreRingView: View {
    let progress: Double

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            backgroundRing
            progressRing
            percentageLabel
        }
        .frame(width: DesignSystem.Size.hero, height: DesignSystem.Size.hero)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animatedProgress = progress
            }
        }
    }
}

// MARK: - Subviews
private extension ScoreRingView {
    var backgroundRing: some View {
        Circle()
            .stroke(
                DesignSystem.Color.cardBackground,
                lineWidth: DesignSystem.Spacing.sm
            )
    }

    var progressRing: some View {
        Circle()
            .trim(from: 0, to: animatedProgress)
            .stroke(
                ringColor,
                style: StrokeStyle(
                    lineWidth: DesignSystem.Spacing.sm,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90))
    }

    var percentageLabel: some View {
        Text("\(Int(animatedProgress * 100))%")
            .font(DesignSystem.Font.largeTitle)
            .foregroundStyle(ringColor)
            .contentTransition(.numericText())
    }
}

// MARK: - Helpers
private extension ScoreRingView {
    var ringColor: Color {
        if progress < 0.4 {
            DesignSystem.Color.error
        } else if progress < 0.7 {
            DesignSystem.Color.warning
        } else {
            DesignSystem.Color.success
        }
    }
}
