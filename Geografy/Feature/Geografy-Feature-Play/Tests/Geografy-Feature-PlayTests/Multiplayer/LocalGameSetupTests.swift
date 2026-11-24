import Geografy_Core_Common
@testable import Geografy_Feature_Play
import Testing

@Suite("Local Play game setup")
struct LocalGameSetupTests {
    @Test("A Word Search grid reaches the other phone letter for letter")
    func wordSearchRoundTrip() throws {
        let puzzle = WordSearchService().makePuzzle(theme: .countries)
        let message = PeerMessage.startGame(config: Self.config(game: .wordSearch), setup: .wordSearch(puzzle))

        let decoded = try PeerMessage.decode(from: message.encode())

        guard case .startGame(let config, .wordSearch(let received)) = decoded else {
            Issue.record("Expected a Word Search start")
            return
        }
        #expect(config.game == .wordSearch)
        #expect(received.grid == puzzle.grid)
        #expect(received.words.map(\.word) == puzzle.words.map(\.word))
        #expect(received.words.map(\.direction) == puzzle.words.map(\.direction))
    }

    @Test("Map Puzzle rounds ask about different countries, each among its own answers")
    func mapPuzzleRounds() {
        let countries = (0..<12).map { SpeedRunNameIndexTests.makeCountry("C\($0)", "Country \($0)") }

        let rounds = MapPuzzleRules.makeRounds(from: countries, requested: .ten)

        #expect(rounds.count == 10)
        #expect(Set(rounds.map(\.answerCode)).count == 10)
        for round in rounds {
            #expect(round.optionCodes.count == MapPuzzleRules.optionsPerQuestion)
            #expect(round.optionCodes.contains(round.answerCode))
            #expect(Set(round.optionCodes).count == round.optionCodes.count)
        }
    }

    @Test("Speed Run and Word Search are races; the others wait for both players", arguments: LocalGame.allCases)
    func races(game: LocalGame) {
        #expect(game.isRace == (game == .speedRun || game == .wordSearch))
    }

    static func config(game: LocalGame) -> PeerMessage.MatchConfig {
        PeerMessage.MatchConfig(
            game: game,
            pinDrop: PinDropConfiguration(region: .world),
            quizType: .flagQuiz,
            region: .world,
            difficulty: .easy,
            questionCount: 10,
            comparisonMetric: .population,
            mapPuzzleContinent: nil,
            mapPuzzleQuestionCount: .ten,
            wordSearchTheme: .countries
        )
    }
}
