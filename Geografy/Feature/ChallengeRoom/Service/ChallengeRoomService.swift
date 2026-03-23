import Foundation

final class ChallengeRoomService {
    func generateRoom(
        player1Name: String,
        player2Name: String,
        totalRounds: Int,
        category: ChallengeCategory,
        countries: [Country]
    ) -> ChallengeRoom {
        let questionCount = totalRounds * 2
        let questions = generateQuestions(
            count: questionCount,
            category: category,
            countries: countries
        )
        return ChallengeRoom(
            player1Name: player1Name,
            player2Name: player2Name,
            player1Score: 0,
            player2Score: 0,
            currentPlayerIndex: 0,
            roundNumber: 1,
            totalRounds: totalRounds,
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

    func winnerName(for room: ChallengeRoom) -> String? {
        if room.player1Score > room.player2Score { return room.player1Name }
        if room.player2Score > room.player1Score { return room.player2Name }
        return nil
    }
}

// MARK: - Helpers

private extension ChallengeRoomService {
    func generateQuestions(count: Int, category: ChallengeCategory, countries: [Country]) -> [ChallengeQuestion] {
        var questions: [ChallengeQuestion] = []
        let shuffled = countries.shuffled()
        let pool = shuffled.prefix(max(count * 4, 40))

        for index in 0..<count {
            let countryIndex = index % pool.count
            let country = pool[pool.startIndex + countryIndex]
            let useCapital = shouldUseCapitals(category: category, index: index)
            let poolArray = Array(pool)
            let question = useCapital
                ? capitalQuestion(for: country, pool: poolArray)
                : flagQuestion(for: country, pool: poolArray)
            questions.append(question)
        }
        return questions
    }

    func shouldUseCapitals(category: ChallengeCategory, index: Int) -> Bool {
        switch category {
        case .capitals: true
        case .flags: false
        case .mixed: index.isMultiple(of: 2)
        }
    }

    func capitalQuestion(for country: Country, pool: [Country]) -> ChallengeQuestion {
        let wrongOptions = pool
            .filter { $0.code != country.code }
            .shuffled()
            .prefix(3)
            .map { $0.capital }

        var options = [country.capital] + wrongOptions
        options.shuffle()
        let correctIndex = options.firstIndex(of: country.capital) ?? 0

        return ChallengeQuestion(
            question: "What is the capital of \(country.name)?",
            options: options,
            correctIndex: correctIndex,
            category: "Capitals"
        )
    }

    func flagQuestion(for country: Country, pool: [Country]) -> ChallengeQuestion {
        let wrongOptions = pool
            .filter { $0.code != country.code }
            .shuffled()
            .prefix(3)
            .map { $0.name }

        var options = [country.name] + wrongOptions
        options.shuffle()
        let correctIndex = options.firstIndex(of: country.name) ?? 0

        return ChallengeQuestion(
            question: "Which country does the flag \(country.flagEmoji) belong to?",
            options: options,
            correctIndex: correctIndex,
            category: "Flags"
        )
    }
}
