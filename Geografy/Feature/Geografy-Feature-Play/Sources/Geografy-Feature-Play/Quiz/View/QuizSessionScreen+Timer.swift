#if !os(tvOS)
import SwiftUI

// MARK: - Timer
extension QuizSessionScreen {
    /// Only the badge ticks; the screen hears from this timer once, when it runs out.
    func startTimer() {
        timerTask?.cancel()
        timerDeadline = nil
        guard configuration.difficulty.hasTimer else { return }

        let remaining = timerRemaining
        timerDeadline = Date.now.addingTimeInterval(remaining)
        timerTask = Task {
            try? await Task.sleep(for: .seconds(remaining))
            guard !Task.isCancelled, !showFeedback, !isPaused else { return }
            timerDeadline = nil
            timerRemaining = 0
            handleTimerExpired()
        }
    }

    func handleTimerExpired() {
        stopTimer()
        guard let question = session.currentQuestion else { return }
        session.timeOut()
        hapticsService.impact(.light)
        typingIsCorrect = false
        let answer = session.correctAnswerText(for: question)
        AccessibilityNotification.Announcement("Time's up. The answer is \(answer).").post()

        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }

        transition.schedule(after: .seconds(1.3)) { advanceToNext() }
    }

    func startArcadeTimer() {
        arcadeTimerTask?.cancel()
        let remaining = arcadeTimeRemaining
        arcadeDeadline = Date.now.addingTimeInterval(remaining)
        arcadeTimerTask = Task {
            try? await Task.sleep(for: .seconds(remaining))
            guard !Task.isCancelled, !isPaused else { return }
            arcadeDeadline = nil
            arcadeTimeRemaining = 0
            finishArcade()
        }
    }

    func finishArcade() {
        stopArcadeTimer()
        stopTimer()
        let result = session.result(arcadeTimeRemaining: arcadeTimeRemaining)
        configuration.announceFinished(accuracy: result.accuracy)
        navigateToResult = result
    }
}
#endif
