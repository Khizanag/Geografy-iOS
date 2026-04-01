import SwiftUI

public struct SessionProgressView: View {
    public let progress: CGFloat
    public let current: Int
    public let total: Int

    public init(progress: CGFloat, current: Int, total: Int) {
        self.progress = progress
        self.current = current
        self.total = total
    }

    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SessionProgressBar(progress: progress)

            QuestionCounterPill(current: current, total: total)
        }
    }
}
