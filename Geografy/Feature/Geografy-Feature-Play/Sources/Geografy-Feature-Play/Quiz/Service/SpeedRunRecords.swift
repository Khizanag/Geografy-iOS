import Foundation
import Geografy_Core_Common

/// The active user's fastest complete Speed Run for each region.
enum SpeedRunRecords {
    /// The best time in seconds, or nil when no complete run has been saved.
    static func bestTime(for region: QuizRegion) -> TimeInterval? {
        let best = UserDefaults.standard.double(forKey: key(for: region))
        return best > 0 ? best : nil
    }

    /// Saves `time` when it beats the stored best. Returns true for a new record.
    @discardableResult
    static func record(_ time: TimeInterval, for region: QuizRegion) -> Bool {
        if let best = bestTime(for: region), best <= time { return false }
        UserDefaults.standard.set(time, forKey: key(for: region))
        return true
    }
}

// MARK: - Helpers
private extension SpeedRunRecords {
    static func key(for region: QuizRegion) -> String {
        UserScope.key("speedrun_best_\(region.rawValue)")
    }
}
