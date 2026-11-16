import Geografy_Core_DesignSystem
import SwiftUI

/// Ticks on its own timeline so the per-second redraw stays in the toolbar, not the whole puzzle.
struct WordSearchClockLabel: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let stopwatch: WordSearchStopwatch

    // MARK: - Body
    var body: some View {
        if let startDate = stopwatch.startDate {
            TimelineView(.periodic(from: startDate, by: 1)) { context in
                label(seconds: stopwatch.wholeSeconds(at: context.date))
            }
        } else {
            label(seconds: stopwatch.wholeSeconds(at: .now))
        }
    }
}

// MARK: - Subviews
private extension WordSearchClockLabel {
    func label(seconds: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "timer")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
                .accessibilityHidden(true)
            Text(WordSearchStopwatch.formatted(seconds: seconds))
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .contentTransition(.numericText())
                .animation(reduceMotion ? nil : .snappy, value: seconds)
                .accessibilityLabel("Elapsed time")
                .accessibilityValue(
                    Duration.seconds(seconds).formatted(.units(allowed: [.minutes, .seconds], width: .wide))
                )
        }
    }
}
