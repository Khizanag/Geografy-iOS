import Foundation

/// Elapsed puzzle time that survives pauses without a ticking counter.
struct WordSearchStopwatch: Equatable, Sendable {
    // MARK: - Properties
    /// While running, the moment the clock would have read zero had it never paused.
    private(set) var startDate: Date?
    private var frozenElapsed: TimeInterval = 0

    var isRunning: Bool { startDate != nil }
}

// MARK: - Reading
extension WordSearchStopwatch {
    func elapsed(at date: Date) -> TimeInterval {
        guard let startDate else { return frozenElapsed }
        return max(0, date.timeIntervalSince(startDate))
    }

    func wholeSeconds(at date: Date) -> Int {
        // Ticks land exactly on whole seconds; snapping first keeps date arithmetic noise from losing one.
        let snapped = (elapsed(at: date) * 1_000).rounded() / 1_000
        return Int(snapped.rounded(.down))
    }

    static func formatted(seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - Control
extension WordSearchStopwatch {
    mutating func resume(at date: Date) {
        guard startDate == nil else { return }
        startDate = date.addingTimeInterval(-frozenElapsed)
    }

    mutating func pause(at date: Date) {
        guard startDate != nil else { return }
        frozenElapsed = elapsed(at: date)
        startDate = nil
    }
}
