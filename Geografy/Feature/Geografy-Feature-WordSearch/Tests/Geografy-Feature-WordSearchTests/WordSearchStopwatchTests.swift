import Foundation
@testable import Geografy_Feature_WordSearch
import Testing

@Suite("WordSearchStopwatch")
struct WordSearchStopwatchTests {
    static let start = Date(timeIntervalSinceReferenceDate: 800_000_000)

    @Test("A new stopwatch is stopped at zero")
    func startsStopped() {
        let stopwatch = WordSearchStopwatch()

        #expect(!stopwatch.isRunning)
        #expect(stopwatch.wholeSeconds(at: Self.start) == 0)
    }

    @Test("A running stopwatch counts whole seconds")
    func countsWholeSeconds() {
        var stopwatch = WordSearchStopwatch()
        stopwatch.resume(at: Self.start)

        #expect(stopwatch.wholeSeconds(at: Self.start.addingTimeInterval(0.9)) == 0)
        #expect(stopwatch.wholeSeconds(at: Self.start.addingTimeInterval(1)) == 1)
        #expect(stopwatch.wholeSeconds(at: Self.start.addingTimeInterval(61.5)) == 61)
    }

    @Test("Paused time does not count")
    func pauseHoldsTime() {
        var stopwatch = WordSearchStopwatch()
        stopwatch.resume(at: Self.start)
        stopwatch.pause(at: Self.start.addingTimeInterval(10))

        #expect(stopwatch.wholeSeconds(at: Self.start.addingTimeInterval(100)) == 10)

        stopwatch.resume(at: Self.start.addingTimeInterval(100))

        #expect(stopwatch.wholeSeconds(at: Self.start.addingTimeInterval(105)) == 15)
    }

    @Test("Resuming a running stopwatch keeps its start")
    func resumeIsIdempotent() {
        var stopwatch = WordSearchStopwatch()
        stopwatch.resume(at: Self.start)
        stopwatch.resume(at: Self.start.addingTimeInterval(30))

        #expect(stopwatch.wholeSeconds(at: Self.start.addingTimeInterval(40)) == 40)
    }

    @Test("Times format as minutes and seconds", arguments: [(0, "00:00"), (9, "00:09"), (75, "01:15")])
    func formats(seconds: Int, expected: String) {
        #expect(WordSearchStopwatch.formatted(seconds: seconds) == expected)
    }
}
