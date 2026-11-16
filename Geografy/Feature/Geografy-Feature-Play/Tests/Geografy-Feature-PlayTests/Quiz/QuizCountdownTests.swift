@testable import Geografy_Feature_Play
import SwiftUI
import Testing

@Suite("QuizCountdown")
struct QuizCountdownTests {
    typealias Countdown = QuizCountdown<EmptyView>

    @Test(
        "Rounding up shows the second still running",
        arguments: [
            (15.0, 15),
            (14.4, 15),
            (14.0000001, 14),
            (13.9999999, 14),
            (0.2, 1),
            (0, 0),
        ]
    )
    func roundingUp(interval: TimeInterval, expected: Int) {
        #expect(Countdown.wholeSeconds(interval, rounding: .up) == expected)
    }

    @Test(
        "Rounding down shows the whole seconds left",
        arguments: [
            (60.0, 60),
            (59.9, 59),
            (58.9999999, 59),
            (0.5, 0),
        ]
    )
    func roundingDown(interval: TimeInterval, expected: Int) {
        #expect(Countdown.wholeSeconds(interval, rounding: .down) == expected)
    }

    @Test("Time past the deadline never shows as negative")
    func pastDeadline() {
        #expect(Countdown.wholeSeconds(-3, rounding: .up) == 0)
        #expect(Countdown.wholeSeconds(-3, rounding: .down) == 0)
    }
}
