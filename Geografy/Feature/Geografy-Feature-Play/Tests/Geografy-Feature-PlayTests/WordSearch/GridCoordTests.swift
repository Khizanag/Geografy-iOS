import CoreGraphics
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

    @Test("A slanted drag snaps to the nearest of the eight directions")
    func snapsToDirection() {
        let start = GridCoord(row: 2, col: 2)

        // Seven down and five across, as in a drag between two diagonals, lands on the diagonal.
        #expect(GridCoord.snappedEnd(from: start, offset: CGVector(dx: 5, dy: 7), gridSize: 12) == GridCoord(row: 8, col: 8))
        // Mostly across, a little down, stays on the row.
        #expect(GridCoord.snappedEnd(from: start, offset: CGVector(dx: 4, dy: 1), gridSize: 12) == GridCoord(row: 2, col: 6))
        // Up and to the left.
        #expect(GridCoord.snappedEnd(from: start, offset: CGVector(dx: -2, dy: -2.2), gridSize: 12) == GridCoord(row: 0, col: 0))
    }

    @Test("A snapped drag stays inside the grid, and a touch that barely moves stays on its cell")
    func snapStaysInGrid() {
        let start = GridCoord(row: 2, col: 9)

        #expect(GridCoord.snappedEnd(from: start, offset: CGVector(dx: 6, dy: 6), gridSize: 12) == GridCoord(row: 4, col: 11))
        #expect(GridCoord.snappedEnd(from: start, offset: CGVector(dx: 0.2, dy: 0.3), gridSize: 12) == start)
    }
}
