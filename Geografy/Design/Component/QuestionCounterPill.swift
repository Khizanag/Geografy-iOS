import SwiftUI

struct QuestionCounterPill: View {
    let current: Int
    let total: Int

    var body: some View {
        Text("\(current)/\(total)")
            .contentTransition(.numericText())
            .font(.system(size: 13, weight: .black, design: .rounded))
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                DesignSystem.Color.cardBackgroundHighlighted,
                in: Capsule()
            )
    }
}
