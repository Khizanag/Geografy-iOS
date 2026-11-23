import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

// MARK: - Actions
extension QuizSessionScreen {
    func togglePause() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isPaused.toggle()
        }
        if isPaused {
            stopTimer()
            stopArcadeTimer()
        } else {
            #if !os(tvOS)
            if !session.isArcade {
                startTimer()
            } else if session.hasArcadeTimer {
                startArcadeTimer()
            }
            #endif
        }
    }

    func selectOption(_ optionID: UUID) {
        guard selectedOptionID == nil, let question = session.currentQuestion else { return }
        stopTimer()
        selectedOptionID = optionID
        let isCorrect = session.answer(option: optionID)
        showAnswerFeedback(isCorrect: isCorrect, question: question, advanceAfter: AnswerFeedback.revealDuration)
    }

    func submitTypingAnswer() {
        guard !showFeedback, let question = session.currentQuestion else { return }
        let trimmedInput = typingInput.trimmingCharacters(in: .whitespaces)
        guard !trimmedInput.isEmpty else { return }
        stopTimer()
        let isCorrect = session.answer(typed: trimmedInput)
        typingIsCorrect = isCorrect
        showAnswerFeedback(isCorrect: isCorrect, question: question, advanceAfter: .seconds(1.5))
    }

    func skipSpellingBee() {
        guard !showFeedback, let question = session.currentQuestion else { return }
        stopTimer()
        session.skip()
        typingIsCorrect = false
        typingWasSkipped = true
        let correctText = session.correctAnswerText(for: question)
        typingInput = correctText
        showAnswerFeedback(
            isCorrect: false,
            question: question,
            announcement: "Skipped. The answer is \(correctText).",
            advanceAfter: .seconds(1.5)
        )
    }

    func advanceToNext() {
        isAwaitingNext = false
        if session.moveToNext() {
            selectedOptionID = nil
            showFeedback = false
            typingInput = ""
            showHint = false
            typingIsCorrect = false
            typingWasSkipped = false
            timerRemaining = configuration.difficulty.timerDuration
            #if !os(tvOS)
            if !session.isArcade {
                startTimer()
            }
            #endif
        } else if session.isArcade {
            #if !os(tvOS)
            finishArcade()
            #else
            finishQuiz()
            #endif
        } else {
            stopTimer()
            finishQuiz()
        }
    }

    /// Stops both timers, keeping the time left for a later resume.
    func stopTimer() {
        if let timerDeadline {
            timerRemaining = max(0, timerDeadline.timeIntervalSinceNow)
        }
        timerDeadline = nil
        timerTask?.cancel()
        timerTask = nil
    }

    func stopArcadeTimer() {
        if let arcadeDeadline {
            arcadeTimeRemaining = max(0, arcadeDeadline.timeIntervalSinceNow)
        }
        arcadeDeadline = nil
        arcadeTimerTask?.cancel()
        arcadeTimerTask = nil
    }

    func finishQuiz() {
        let result = session.result()
        configuration.announceFinished(accuracy: result.accuracy)
        finishedResult = result
    }

    /// Waits for country data, so a quiz opened at launch doesn't settle on an empty question list.
    func loadQuiz() {
        session.load(countries: countryDataService.countries)
        guard session.hasLoaded else { return }
        isAwaitingNext = false
        selectedOptionID = nil
        showFeedback = false
        typingInput = ""
        showHint = false
        typingIsCorrect = false
        typingWasSkipped = false
        showStreakBurst = false
        #if !os(tvOS)
        if session.isArcade {
            arcadeTimeRemaining = configuration.arcadeTimer.duration ?? 0
            if session.hasArcadeTimer {
                startArcadeTimer()
            }
        } else {
            timerRemaining = configuration.difficulty.timerDuration
            startTimer()
        }
        #endif
    }
}

// MARK: - Feedback
extension QuizSessionScreen {
    /// The haptic, the spoken result, the streak burst, and the reveal that follow every answer, then the next
    /// question; an arcade game out of lives ends instead.
    func showAnswerFeedback(
        isCorrect: Bool,
        question: QuizQuestion,
        announcement: String? = nil,
        advanceAfter delay: Duration
    ) {
        checkedAnswer = AnswerFeedback(soundService: soundService).play(
            isCorrect: isCorrect,
            announcement: announcement ?? spokenResult(isCorrect: isCorrect, question: question)
        )
        if isCorrect, session.streak >= 2 {
            showStreakBurst = true
            streakBurstEnd.schedule(after: .seconds(0.3)) { showStreakBurst = false }
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }

        moveOn(afterCorrectAnswer: isCorrect, delay: delay)
    }

    /// Moves on by itself, or waits on the answer until the player taps Next, as the quiz setup chose.
    func moveOn(afterCorrectAnswer isCorrect: Bool, delay: Duration) {
        guard answerAdvance.movesOn(afterCorrectAnswer: isCorrect) else {
            stopArcadeTimer()
            withAnimation(.easeInOut(duration: 0.25)) {
                isAwaitingNext = true
            }
            return
        }
        if session.isOutOfLives {
            #if !os(tvOS)
            transition.schedule(after: .seconds(1)) { finishArcade() }
            #endif
        } else {
            transition.schedule(after: delay) { advanceToNext() }
        }
    }

    /// Next, after waiting on an answer: the arcade clock, held while the player read, runs again.
    func continueAfterAnswer() {
        isAwaitingNext = false
        #if !os(tvOS)
        if session.isOutOfLives {
            finishArcade()
            return
        }
        if session.isArcade, session.hasArcadeTimer {
            startArcadeTimer()
        }
        #endif
        advanceToNext()
    }

    func showCountry(_ country: Country) {
        coordinator.sheet(CountryRoute.countryDetail(country))
    }

    func spokenResult(isCorrect: Bool, question: QuizQuestion) -> String {
        guard isCorrect else {
            return AnswerFeedback.incorrectAnnouncement(answer: session.correctAnswerText(for: question))
        }
        return session.streak >= 2 ? "Correct. \(session.streak) in a row." : "Correct."
    }
}
