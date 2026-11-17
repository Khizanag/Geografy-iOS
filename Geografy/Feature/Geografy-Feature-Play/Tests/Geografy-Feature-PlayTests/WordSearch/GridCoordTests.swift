@testable import Geografy_Feature_Play
import Testing

@Suite("Grid selection")
struct GridCoordTests {
    @Test("A drag across, down, or diagonally covers every cell between its ends")
    func straightLines() {
        let start = GridCoord(row: 2, col: 2)

        #expect(GridCoord.line(from: start, to: GridCoord(row: 2, col: 5)).count == 4)
        #expect(GridCoord.line(from: start, to: GridCoord(row: 0, col: 2)).map(\.row) == [2, 1, 0])
        #expect(
            GridCoord.line(from: start, to: GridCoord(row: 4, col: 0))
                == [start, GridCoord(row: 3, col: 1), GridCoord(row: 4, col: 0)]
        )
    }

    @Test("A drag at any other angle, or none at all, selects only where it started")
    func otherAngles() {
        let start = GridCoord(row: 0, col: 0)

        #expect(GridCoord.line(from: start, to: GridCoord(row: 1, col: 3)) == [start])
        #expect(GridCoord.line(from: start, to: start) == [start])
    }
}
