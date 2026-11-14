import Geografy_Core_DesignSystem
import SwiftUI

/// Ticks on its own timeline so the 10 Hz redraw stays inside this view, not the whole run screen.
struct SpeedRunClock: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let startDate: Date
    let isComplete: Bool

    @ScaledMetric(relativeTo: .largeTitle) private var fontSize: CGFloat = 44

    // MARK: - Body
    var body: some View {
        TimelineView(.periodic(from: startDate, by: 0.1)) { context in
            clockContent(elapsed: max(0, context.date.timeIntervalSince(startDate)))
        }
    }
}

// MARK: - Subviews
private extension SpeedRunClock {
    func clockContent(elapsed: TimeInterval) -> some View {
        let color = timerColor(elapsed: elapsed)
        return HStack(spacing: DesignSystem.Spacing.xs) {
            if let symbol = statusSymbol(elapsed: elapsed) {
                Image(systemName: symbol)
                    .font(DesignSystem.Font.iconMedium)
                    .foregroundStyle(color)
                    .accessibilityHidden(true)
            }
            Text(Self.formatted(elapsed))
                .font(DesignSystem.Font.system(size: fontSize, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .contentTransition(.numericText())
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.1), value: Self.tenths(elapsed))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Elapsed time")
        .accessibilityValue(Self.spokenValue(elapsed, isComplete: isComplete))
    }
}

// MARK: - Formatting
extension SpeedRunClock {
    static let overTimeThreshold: TimeInterval = 300

    static func formatted(_ elapsed: TimeInterval) -> String {
        let totalSeconds = Int(elapsed)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let tenths = Int((elapsed.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }

    static func spokenValue(_ elapsed: TimeInterval, isComplete: Bool) -> String {
        let spoken = Duration.seconds(Int(elapsed))
            .formatted(.units(allowed: [.minutes, .seconds], width: .wide))
        let isOverTime = elapsed > overTimeThreshold && !isComplete
        return isOverTime ? "\(spoken), over 5 minutes" : spoken
    }
}

// MARK: - Helpers
private extension SpeedRunClock {
    static func tenths(_ elapsed: TimeInterval) -> Int {
        Int(elapsed * 10)
    }

    func timerColor(elapsed: TimeInterval) -> Color {
        if isComplete {
            DesignSystem.Color.success
        } else if elapsed > Self.overTimeThreshold {
            DesignSystem.Color.error
        } else {
            DesignSystem.Color.textPrimary
        }
    }

    func statusSymbol(elapsed: TimeInterval) -> String? {
        if isComplete {
            "checkmark.circle.fill"
        } else if elapsed > Self.overTimeThreshold {
            "exclamationmark.triangle.fill"
        } else {
            nil
        }
    }
}
