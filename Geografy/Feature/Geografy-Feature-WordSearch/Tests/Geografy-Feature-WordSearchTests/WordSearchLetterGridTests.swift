import Foundation
@testable import Geografy_Feature_WordSearch
import Testing

@MainActor
@Suite("WordSearchLetterGrid")
struct WordSearchLetterGridTests {
    static let grid: [[Character]] = [["A", "B"], ["C", "D"]]

    @Test("Rows are spoken letter by letter")
    func spokenRows() {
        #expect(WordSearchLetterGrid.spokenRows(of: Self.grid) == ["A B", "C D"])
    }

    @Test("The grid redraws only for a new puzzle or cell size")
    func equality() {
        let puzzleID = UUID()
        let grid = makeGrid(puzzleID: puzzleID, cellSize: 30)

        #expect(grid == makeGrid(puzzleID: puzzleID, cellSize: 30))
        #expect(grid != makeGrid(puzzleID: UUID(), cellSize: 30))
        #expect(grid != makeGrid(puzzleID: puzzleID, cellSize: 31))
    }

    func makeGrid(puzzleID: UUID, cellSize: CGFloat) -> WordSearchLetterGrid {
        WordSearchLetterGrid(
            puzzleID: puzzleID,
            grid: Self.grid,
            spokenRows: WordSearchLetterGrid.spokenRows(of: Self.grid),
            cellSize: cellSize
        )
    }
}
