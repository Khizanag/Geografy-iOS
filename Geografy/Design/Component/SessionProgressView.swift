import Geografy_Core_DesignSystem
import SwiftUI

struct SessionProgressView: View {
    let progress: CGFloat
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SessionProgressBar(progress: progress)

            QuestionCounterPill(current: current, total: total)
        }
    }
}
