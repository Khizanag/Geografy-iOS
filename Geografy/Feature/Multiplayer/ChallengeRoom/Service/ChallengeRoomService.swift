import Foundation
import GeografyCore

final class ChallengeRoomService {
    struct RoomConfiguration {
        let player1Name: String
        let player2Name: String
        let totalRounds: Int
        let quizType: QuizType
        let comparisonMetric: ComparisonMetric
        let countries: [Country]
    }

    func generateRoom(configuration: RoomConfiguration) -> ChallengeRoom {
        let questionCount = configuration.totalRounds * 2
        let questions = generateQuestions(
            count: questionCount,
            quizType: configuration.quizType,
            comparisonMetric: configuration.comparisonMetric,
            countries: configuration.countries
        )
        return ChallengeRoom(
            player1Name: configuration.player1Name,
            player2Name: configuration.player2Name,
            player1Score: 0,
            player2Score: 0,
            currentPlayerIndex: 0,
            roundNumber: 1,
            totalRounds: configuration.totalRounds,
            questions: questions
        )
    }

    func score(room: inout ChallengeRoom, wasCorrect: Bool) {
        if wasCorrect {
            if room.currentPlayerIndex == 0 {
                room.player1Score += 1
            } else {
                room.player2Score += 1
            }
        }
    }

    func advance(room: inout ChallengeRoom) {
        if room.currentPlayerIndex == 0 {
            room.currentPlayerIndex = 1
        } else {
            room.currentPlayerIndex = 0
            room.roundNumber += 1
        }
    }
}

// MARK: - Helpers
private extension ChallengeRoomService {
    func generateQuestions(
        count: Int,
        quizType: QuizType,
        comparisonMetric: ComparisonMetric,
        countries: [Country]
    ) -> [ChallengeQuestion] {
        let quizQuestions = QuestionGenerator.generate(
            type: quizType,
            countries: countries,
            count: count,
            optionCount: 4,
            comparisonMetric: comparisonMetric
        )

        return quizQuestions.map { quizQuestion in
            let options = quizQuestion.options.map { $0.text ?? $0.flagCode ?? "" }
            let correctIndex = quizQuestion.options.firstIndex { $0.id == quizQuestion.correctOptionID } ?? 0

            return ChallengeQuestion(
                question: [quizQuestion.promptText, quizQuestion.promptSubject]
                    .compactMap { $0 }
                    .joined(separator: " "),
                options: options,
                correctIndex: correctIndex
            )
        }
        .shuffled()
    }
}
