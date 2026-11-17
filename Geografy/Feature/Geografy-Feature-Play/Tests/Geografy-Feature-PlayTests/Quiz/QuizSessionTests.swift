import Foundation
import Geografy_Core_Common
@testable import Geografy_Feature_Play
import Testing

@MainActor
@Suite("Quiz session")
struct QuizSessionTests {
    @Test("Loading builds the asked number of questions and starts at the first")
    func loadBuildsQuestions() {
        let session = Self.makeSession()

        session.load(countries: Self.countries)

        #expect(session.hasLoaded)
        #expect(session.questions.count == 5)
        #expect(session.currentIndex == 0)
        #expect(session.progress == 0)
    }

    @Test("A quiz opened before countries load waits instead of settling on no questions")
    func waitsForCountries() {
        let session = Self.makeSession()

        session.load(countries: [])

        #expect(!session.hasLoaded)
    }

    @Test("Right answers build a streak and a wrong one resets it")
    func streak() throws {
        let session = Self.makeSession()
        session.load(countries: Self.countries)

        #expect(try answerRight(session))
        _ = session.moveToNext()
        #expect(try answerRight(session))
        #expect(session.streak == 2)

        _ = session.moveToNext()
        answerWrong(session)
        #expect(session.streak == 0)
        #expect(session.answers.map(\.isCorrect) == [true, true, false])
    }

    @Test("Arcade scores right answers and ends after three wrong ones")
    func arcadeLives() throws {
        let session = Self.makeSession(gameMode: .arcade)
        session.load(countries: Self.countries)

        #expect(try answerRight(session))
        #expect(session.arcadeScore == QuizSession.arcadePointsPerCorrect)

        for _ in 0..<QuizSession.arcadeLives {
            _ = session.moveToNext()
            answerWrong(session)
        }
        #expect(session.lives == 0)
        #expect(session.isOutOfLives)
    }

    @Test("A typed answer ignores case, accents, and punctuation")
    func typedAnswer() throws {
        let session = Self.makeSession(answerMode: .typing)
        session.load(countries: Self.countries)
        let question = try #require(session.currentQuestion)
        let typed = question.correctCountry.name
            .uppercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurrences(of: "'", with: "")

        #expect(session.answer(typed: "  \(typed) "))
    }

    @Test("A wrong typed answer, a skip, and a timeout all count as wrong")
    func wrongWaysToAnswer() {
        let session = Self.makeSession(answerMode: .typing)
        session.load(countries: Self.countries)

        #expect(!session.answer(typed: "Atlantis"))
        _ = session.moveToNext()
        session.skip()
        _ = session.moveToNext()
        session.timeOut()

        #expect(session.answers.count == 3)
        #expect(session.answers.allSatisfy { !$0.isCorrect })
        #expect(session.answers.last?.timeSpent == QuizDifficulty.easy.timerDuration)
    }

    @Test("The last question has no next one, and the result counts every answer")
    func finishes() throws {
        let session = Self.makeSession()
        session.load(countries: Self.countries)

        var moved = true
        while moved {
            #expect(try answerRight(session))
            moved = session.moveToNext()
        }
        let result = session.result()

        #expect(result.answers.count == 5)
        #expect(result.correctCount == 5)
    }

    @Test("A timed arcade game counts the time it used")
    func arcadeTime() {
        let session = Self.makeSession(gameMode: .arcade)
        session.load(countries: Self.countries)

        let result = session.result(arcadeTimeRemaining: 15)

        #expect(result.totalTime == 45)
    }
}

// MARK: - Helpers
private extension QuizSessionTests {
    static let countries = ["FR", "DE", "IT", "ES", "PT", "NL", "BE", "CI"].map { code in
        SpeedRunNameIndexTests.makeCountry(code, code == "CI" ? "Côte d'Ivoire" : "Country \(code)")
    }

    static func makeSession(
        gameMode: QuizGameMode = .standard,
        answerMode: QuizAnswerMode = .multipleChoice
    ) -> QuizSession {
        QuizSession(configuration: QuizConfiguration(
            type: .flagQuiz,
            region: .world,
            difficulty: .easy,
            questionCount: .five,
            answerMode: answerMode,
            comparisonMetric: .population,
            gameMode: gameMode
        ))
    }

    func answerRight(_ session: QuizSession) throws -> Bool {
        let question = try #require(session.currentQuestion)
        return session.answer(option: question.correctOptionID)
    }

    func answerWrong(_ session: QuizSession) {
        session.answer(option: UUID())
    }
}
