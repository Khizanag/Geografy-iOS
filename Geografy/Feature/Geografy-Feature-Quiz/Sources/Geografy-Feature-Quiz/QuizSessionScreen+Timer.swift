#if !os(tvOS)
import Combine
import SwiftUI

// MARK: - Timer
extension QuizSessionScreen {
    public func startTimer() {
        timerCancellable?.cancel()
        guard configuration.difficulty.hasTimer else { return }

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                guard !showFeedback, !isPaused else { return }

                withAnimation(.easeInOut(duration: 0.3)) {
                    timerRemaining -= 1
                }

                if timerRemaining <= 0 {
                    handleTimerExpired()
                }
            }
    }

    public func handleTimerExpired() {
        timerCancellable?.cancel()

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

        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            advanceToNext()
        }
    }

    public func startArcadeTimer() {
        arcadeTimerCancellable?.cancel()
        arcadeTimerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                guard !isPaused else { return }
                arcadeTimeRemaining = max(0, arcadeTimeRemaining - 0.1)
                if arcadeTimeRemaining <= 0 {
                    arcadeTimerCancellable?.cancel()
                    finishArcade()
                }
            }
    }

    public func finishArcade() {
        arcadeTimerCancellable?.cancel()
        timerCancellable?.cancel()
        let result = QuizResult(
            configuration: configuration,
            answers: answers,
            totalTime: 60 - arcadeTimeRemaining,
        )
        navigateToResult = result
    }
}
#endif
