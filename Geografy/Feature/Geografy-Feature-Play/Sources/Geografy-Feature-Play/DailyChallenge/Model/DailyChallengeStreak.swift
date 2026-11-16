import Foundation

/// A player's run of daily challenges, worked out from the days they finished one.
struct DailyChallengeStreak: Equatable {
    // MARK: - Day
    struct Day: Identifiable, Equatable {
        enum State: Equatable {
            case done
            case missed
            /// Today, not played yet: it can still count.
            case pending
        }

        let date: Date
        let state: State

        var id: Date { date }
    }

    // MARK: - Status
    enum Status: Equatable {
        case notStarted
        /// The streak lives on from yesterday but ends unless today's challenge is played.
        case atRisk(days: Int)
        /// Today's challenge is done and counted.
        case extended(days: Int)
    }

    // MARK: - Properties
    static let weekLength = 7

    let current: Int
    let best: Int
    let completedCount: Int
    let lastWeek: [Day]
    let isTodayDone: Bool

    var status: Status {
        if isTodayDone {
            return .extended(days: current)
        }
        return current > 0 ? .atRisk(days: current) : .notStarted
    }

    // MARK: - Init
    init(dateKeys: some Sequence<String>, today: Date = .now, calendar: Calendar = .current) {
        let playedDays = Set(dateKeys.compactMap { DailyChallengeResult.date(forKey: $0, calendar: calendar) })
        let today = calendar.startOfDay(for: today)
        let isTodayDone = playedDays.contains(today)
        let streakEnd = isTodayDone ? today : Self.day(before: today, calendar: calendar)

        self.isTodayDone = isTodayDone
        self.current = Self.run(endingAt: streakEnd, in: playedDays, calendar: calendar)
        self.best = Self.longestRun(in: playedDays, calendar: calendar)
        self.completedCount = playedDays.count
        self.lastWeek = (0..<Self.weekLength).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)
                .map { calendar.startOfDay(for: $0) } ?? today
            let state: Day.State = if playedDays.contains(date) {
                .done
            } else {
                offset == 0 ? .pending : .missed
            }
            return Day(date: date, state: state)
        }
    }
}

// MARK: - Helpers
private extension DailyChallengeStreak {
    static func day(before date: Date, calendar: Calendar) -> Date {
        calendar.date(byAdding: .day, value: -1, to: date).map { calendar.startOfDay(for: $0) } ?? date
    }

    static func run(endingAt end: Date, in days: Set<Date>, calendar: Calendar) -> Int {
        var count = 0
        var cursor = end
        while days.contains(cursor) {
            count += 1
            let previous = day(before: cursor, calendar: calendar)
            guard previous != cursor else { break }
            cursor = previous
        }
        return count
    }

    static func longestRun(in days: Set<Date>, calendar: Calendar) -> Int {
        var best = 0
        var length = 0
        var previous: Date?
        for date in days.sorted() {
            let follows = previous.map { day(before: date, calendar: calendar) == $0 } ?? false
            length = follows ? length + 1 : 1
            best = max(best, length)
            previous = date
        }
        return best
    }
}
