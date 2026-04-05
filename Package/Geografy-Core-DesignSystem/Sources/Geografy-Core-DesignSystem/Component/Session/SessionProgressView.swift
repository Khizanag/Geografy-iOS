import SwiftUI

public struct SessionProgressView: View {
    // MARK: - Properties
    public let progress: CGFloat
    public let current: Int
    public let total: Int

    // MARK: - Init
    public init(progress: CGFloat, current: Int, total: Int) {
        self.progress = progress
        self.current = current
        self.total = total
    }

    // MARK: - Body
    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SessionProgressBar(progress: progress)

            QuestionCounterPill(current: current, total: total)
        }
    }
}
