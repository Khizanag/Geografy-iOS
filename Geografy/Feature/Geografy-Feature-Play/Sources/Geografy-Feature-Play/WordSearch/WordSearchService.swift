import Foundation
import Geografy_Core_Common

public struct WordSearchService {
    public let gridSize = 12

    public func makePuzzle(theme: WordSearchTheme) -> WordSearchPuzzle {
        var grid = emptyGrid()
        var placedWords: [WordSearchWord] = []

        let wordsToPlace = theme.words.shuffled()

        for word in wordsToPlace {
            if let placed = attemptToPlace(word: word, in: &grid) {
                placedWords.append(placed)
            }
        }

        fillRemainingCells(in: &grid)

        return WordSearchPuzzle(
            id: UUID(),
            theme: theme,
            grid: grid,
            words: placedWords
        )
    }

    public func delta(for direction: WordSearchDirection) -> (rowDelta: Int, colDelta: Int) {
        switch direction {
        case .horizontal: (0, 1)
        case .horizontalReverse: (0, -1)
        case .vertical: (1, 0)
        case .verticalReverse: (-1, 0)
        case .diagonalDown: (1, 1)
        case .diagonalUp: (-1, 1)
        }
    }
}

// MARK: - Grid Building
private extension WordSearchService {
    func emptyGrid() -> [[Character]] {
        Array(repeating: Array(repeating: Character(" "), count: gridSize), count: gridSize)
    }

    func attemptToPlace(word: String, in grid: inout [[Character]]) -> WordSearchWord? {
        let directions = WordSearchDirection.allCases.shuffled()
        let maxAttempts = 50
        var attempts = 0

        while attempts < maxAttempts {
            let direction = directions[attempts % directions.count]
            let row = Int.random(in: 0..<gridSize)
            let col = Int.random(in: 0..<gridSize)

            if canPlace(word: word, at: row, col: col, direction: direction, in: grid) {
                placeWord(word, at: row, col: col, direction: direction, in: &grid)
                return WordSearchWord(
                    id: UUID(),
                    word: word,
                    startRow: row,
                    startCol: col,
                    direction: direction,
                    isFound: false
                )
            }
            attempts += 1
        }

        return nil
    }

    func canPlace(
        word: String,
        at startRow: Int,
        col startCol: Int,
        direction: WordSearchDirection,
        in grid: [[Character]]
    ) -> Bool {
        let (rowDelta, colDelta) = delta(for: direction)
        let letters = Array(word)

        for index in 0..<letters.count {
            let row = startRow + rowDelta * index
            let col = startCol + colDelta * index

            guard row >= 0, row < gridSize, col >= 0, col < gridSize else { return false }

            let existing = grid[row][col]
            guard existing == Character(" ") || existing == letters[index] else { return false }
        }

        return true
    }

    func placeWord(
        _ word: String,
        at startRow: Int,
        col startCol: Int,
        direction: WordSearchDirection,
        in grid: inout [[Character]]
    ) {
        let (rowDelta, colDelta) = delta(for: direction)
        let letters = Array(word)

        for index in 0..<letters.count {
            let row = startRow + rowDelta * index
            let col = startCol + colDelta * index
            grid[row][col] = letters[index]
        }
    }

    func fillRemainingCells(in grid: inout [[Character]]) {
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        for row in 0..<gridSize {
            for col in 0..<gridSize where grid[row][col] == Character(" ") {
                grid[row][col] = letters.randomElement() ?? "A"
            }
        }
    }
}
