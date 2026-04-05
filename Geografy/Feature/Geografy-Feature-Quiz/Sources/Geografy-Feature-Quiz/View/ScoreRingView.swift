import Geografy_Core_DesignSystem
import SwiftUI

public struct ScoreRingView: View {
    // MARK: - Properties
    public let progress: Double

    @State private var animatedProgress: Double = 0
    @State private var displayPercent: Int = 0

    // MARK: - Init
    public init(progress: Double) {
        self.progress = progress
    }

    // MARK: - Body
    public var body: some View {
        ZStack {
            backgroundRing
            progressRing
            percentageLabel
        }
        .frame(width: 120, height: 120)
        .onAppear { startCountUp() }
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
        Text("\(displayPercent)%")
            .font(DesignSystem.Font.largeTitle)
            .foregroundStyle(ringColor)
            .contentTransition(.numericText(countsDown: false))
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

    func startCountUp() {
        let targetPercent = Int(progress * 100)
        guard targetPercent > 0 else { return }

        withAnimation(.easeOut(duration: 1.2)) {
            animatedProgress = progress
        }

        let totalDuration: Double = 1.2
        let stepCount = targetPercent
        let interval = totalDuration / Double(stepCount)

        for step in 1...stepCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(step)) {
                withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.8)) {
                    displayPercent = step
                }
            }
        }
    }
}
