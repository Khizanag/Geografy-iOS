#if !os(tvOS)
import SwiftUI

// MARK: - Timer
extension QuizSessionScreen {
    /// Only the badge ticks; the screen hears from this timer once, when it runs out.
    public func startTimer() {
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

    public func handleTimerExpired() {
        stopTimer()

        let question = questions[currentIndex]
        let timeSpent = configuration.difficulty.timerDuration

        hapticsService.impact(.light)
        currentStreak = 0

        let answer = QuizAnswer(
            id: UUID(),
            question: question,
            selectedOptionID: nil,
            isCorrect: false,
            timeSpent: timeSpent
        )
        answers.append(answer)
        typingIsCorrect = false
        AccessibilityNotification.Announcement("Time's up. The answer is \(correctAnswerText(for: question)).").post()

        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }

        scheduleTransition(after: .seconds(1.3)) { advanceToNext() }
    }

    public func startArcadeTimer() {
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

    public func finishArcade() {
        stopArcadeTimer()
        stopTimer()
        let totalTime: TimeInterval
        if let duration = configuration.arcadeTimer.duration {
            totalTime = duration - arcadeTimeRemaining
        } else {
            totalTime = Date().timeIntervalSince(startTime)
        }
        let result = QuizResult(
            configuration: configuration,
            answers: answers,
            totalTime: totalTime,
        )
        navigateToResult = result
    }
}
#endif
