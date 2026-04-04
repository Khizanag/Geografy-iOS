import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

// MARK: - Actions
extension QuizSessionScreen {
    public func togglePause() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isPaused.toggle()
        }
        if isPaused {
            timerCancellable?.cancel()
        } else {
            #if !os(tvOS)
            startTimer()
            #endif
        }
    }

    public func selectOption(_ optionID: UUID) {
        guard selectedOptionID == nil else { return }
        timerCancellable?.cancel()
        selectedOptionID = optionID

        let question = questions[currentIndex]
        let isCorrect = optionID == question.correctOptionID
        let timeSpent = Date().timeIntervalSince(questionStartTime)

        handleAnswerFeedback(isCorrect: isCorrect)

        let answer = QuizAnswer(
            id: UUID(),
            question: question,
            selectedOptionID: optionID,
            isCorrect: isCorrect,
            timeSpent: timeSpent
        )
        answers.append(answer)

        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }

        if isArcadeMode, arcadeLives <= 0 { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            advanceToNext()
        }
    }

    public func handleAnswerFeedback(isCorrect: Bool) {
        if isCorrect {
            hapticsService.notification(.success)
            currentStreak += 1
            if isArcadeMode {
                arcadeScore += 10
            }
            if currentStreak >= 2 {
                showStreakBurst = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showStreakBurst = false
                }
            }
        } else {
            hapticsService.impact(.light)
            currentStreak = 0
            if isArcadeMode {
                arcadeLives -= 1
                if arcadeLives <= 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        #if !os(tvOS)
                        finishArcade()
                        #endif
                    }
                }
            }
        }
    }

    public func advanceToNext() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedOptionID = nil
            showFeedback = false
            typingInput = ""
            showHint = false
            typingIsCorrect = false
            typingWasSkipped = false
            questionStartTime = Date()
            timerRemaining = configuration.difficulty.timerDuration
            if !isArcadeMode {
                #if !os(tvOS)
                startTimer()
                #endif
            }
        } else if isArcadeMode {
            #if !os(tvOS)
            finishArcade()
            #else
            finishQuiz()
            #endif
        } else {
            timerCancellable?.cancel()
            finishQuiz()
        }
    }

    public func submitTypingAnswer() {
        guard !showFeedback else { return }
        let trimmedInput = typingInput.trimmingCharacters(in: .whitespaces)
        guard !trimmedInput.isEmpty else { return }

        timerCancellable?.cancel()

        let question = questions[currentIndex]
        let isCorrect = isTypingAnswerCorrect(input: trimmedInput, question: question)
        let timeSpent = Date().timeIntervalSince(questionStartTime)

        handleAnswerFeedback(isCorrect: isCorrect)

        let answer = QuizAnswer(
            id: UUID(),
            question: question,
            selectedOptionID: isCorrect ? question.correctOptionID : nil,
            isCorrect: isCorrect,
            timeSpent: timeSpent,
        )
        answers.append(answer)
        typingIsCorrect = isCorrect

        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }

        if isArcadeMode, arcadeLives <= 0 { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            advanceToNext()
        }
    }

    public func skipSpellingBee() {
        guard !showFeedback else { return }
        timerCancellable?.cancel()

        let question = questions[currentIndex]
        let timeSpent = Date().timeIntervalSince(questionStartTime)

        handleAnswerFeedback(isCorrect: false)

        let answer = QuizAnswer(
            id: UUID(),
            question: question,
            selectedOptionID: nil,
            isCorrect: false,
            timeSpent: timeSpent,
        )
        answers.append(answer)
        typingIsCorrect = false
        typingWasSkipped = true

        let correctText = spellingBeeCorrectText(for: question)
        typingInput = correctText

        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }

        if isArcadeMode, arcadeLives <= 0 { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            advanceToNext()
        }
    }

    public func finishQuiz() {
        let totalTime = Date().timeIntervalSince(startTime)
        navigateToResult = QuizResult(
            configuration: configuration,
            answers: answers,
            totalTime: totalTime
        )
    }

    public func loadQuiz() {
        let pool = configuration.region.filter(countryDataService.countries)
        let optionCount = max(configuration.difficulty.optionCount, 4)
        guard pool.count >= optionCount else { return }

        let questionCount = isArcadeMode
            ? min(100, pool.count)
            : min(configuration.questionCount.rawValue, pool.count)

        questions = QuestionGenerator.generate(
            type: configuration.type,
            countries: pool,
            count: questionCount,
            optionCount: optionCount,
            comparisonMetric: configuration.comparisonMetric
        )
        currentIndex = 0
        answers = []
        selectedOptionID = nil
        showFeedback = false
        typingInput = ""
        showHint = false
        typingIsCorrect = false
        typingWasSkipped = false
        currentStreak = 0
        showStreakBurst = false
        startTime = Date()
        questionStartTime = Date()

        if isArcadeMode {
            arcadeLives = 3
            arcadeScore = 0
            arcadeTimeRemaining = configuration.arcadeTimer.duration ?? 0
            #if !os(tvOS)
            if configuration.arcadeTimer.duration != nil {
                startArcadeTimer()
            }
            #endif
        } else {
            timerRemaining = configuration.difficulty.timerDuration
            #if !os(tvOS)
            startTimer()
            #endif
        }
    }

    public var isArcadeMode: Bool {
        configuration.gameMode == .arcade
    }

    public var hasArcadeTimer: Bool {
        configuration.arcadeTimer.duration != nil
    }
}
