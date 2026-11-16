import SwiftUI

/// Counts whole seconds down to `deadline` on its own timeline, so each tick redraws only `content`.
struct QuizCountdown<Content: View>: View {
    // MARK: - Properties
    /// When the countdown hits zero; nil while it is stopped.
    let deadline: Date?
    /// Seconds left while stopped, or when the running countdown last started.
    let remaining: TimeInterval
    let rounding: FloatingPointRoundingRule
    @ViewBuilder let content: (Int) -> Content

    // MARK: - Body
    var body: some View {
        TimelineView(.explicit(tickDates)) { context in
            content(seconds(at: context.date))
        }
    }
}

// MARK: - Helpers
private extension QuizCountdown {
    /// The shown value only changes when the time left crosses a whole second.
    var tickDates: [Date] {
        guard let deadline else { return [] }
        let tickCount = Int(remaining.rounded(.up))
        return (0...tickCount)
            .reversed()
            .map { deadline.addingTimeInterval(-Double($0)) }
    }

    func seconds(at date: Date) -> Int {
        guard let deadline else { return Self.wholeSeconds(remaining, rounding: rounding) }
        return Self.wholeSeconds(deadline.timeIntervalSince(date), rounding: rounding)
    }
}

// MARK: - Rounding
extension QuizCountdown {
    static func wholeSeconds(_ interval: TimeInterval, rounding: FloatingPointRoundingRule) -> Int {
        // Ticks land exactly on whole seconds; snapping first keeps date arithmetic noise from skipping one.
        let snapped = (max(0, interval) * 1_000).rounded() / 1_000
        return Int(snapped.rounded(rounding))
    }
}
