import SwiftUI

public struct QuestionCounterPill: View {
    public let current: Int
    public let total: Int

    public init(current: Int, total: Int) {
        self.current = current
        self.total = total
    }

    public var body: some View {
        Text("\(current)/\(total)")
            .contentTransition(.numericText())
            .font(DesignSystem.Font.roundedMicro)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                DesignSystem.Color.cardBackgroundHighlighted,
                in: Capsule()
            )
            .accessibilityLabel("Question \(current) of \(total)")
    }
}
