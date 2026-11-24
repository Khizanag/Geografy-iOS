import SwiftUI

struct GridCoord: Hashable, Sendable {
    let row: Int
    let col: Int

    /// The cells a drag from `start` to `end` covers: a straight run across, down, or at 45 degrees, or just
    /// `start` when the drag goes another way.
    static func line(from start: GridCoord, to end: GridCoord) -> [GridCoord] {
        let rowDelta = end.row - start.row
        let colDelta = end.col - start.col
        let steps = max(abs(rowDelta), abs(colDelta))
        guard steps > 0, rowDelta == 0 || colDelta == 0 || abs(rowDelta) == abs(colDelta) else { return [start] }
        let rowStep = rowDelta.signum()
        let colStep = colDelta.signum()
        return (0...steps).map { GridCoord(row: start.row + rowStep * $0, col: start.col + colStep * $0) }
    }

    /// Where a drag from `start` ends once it's held to a straight line: the finger's direction rounded to the
    /// nearest of the eight a word can run, and its reach along that direction rounded to whole cells, kept
    /// inside the grid. So the selection is always a run a word could fill, never a slant between cells.
    /// - Parameter offset: How far the finger is from the center of `start`, in cells.
    static func snappedEnd(from start: GridCoord, offset: CGVector, gridSize: Int) -> GridCoord {
        guard hypot(offset.dx, offset.dy) >= 0.5 else { return start }
        let octant = (atan2(offset.dy, offset.dx) / (.pi / 4)).rounded()
        let angle = octant * .pi / 4
        let colStep = Int(cos(angle).rounded())
        let rowStep = Int(sin(angle).rounded())
        // The reach along the direction, in steps: a diagonal step is one cell across and one down.
        let reach = (offset.dx * CGFloat(colStep) + offset.dy * CGFloat(rowStep))
            / CGFloat(colStep * colStep + rowStep * rowStep)
        let steps = min(Int(reach.rounded()), room(from: start, rowStep: rowStep, colStep: colStep, gridSize: gridSize))
        return GridCoord(row: start.row + rowStep * steps, col: start.col + colStep * steps)
    }

    /// How many steps fit from `start` before the grid's edge.
    private static func room(from start: GridCoord, rowStep: Int, colStep: Int, gridSize: Int) -> Int {
        func roomAlong(_ position: Int, _ step: Int) -> Int {
            switch step {
            case 1: gridSize - 1 - position
            case -1: position
            default: .max
            }
        }
        return min(roomAlong(start.row, rowStep), roomAlong(start.col, colStep))
    }
}

/// The highlight laid over a run of grid cells, for found, revealed and in-progress words.
struct WordSearchCapsule: View {
    // MARK: - Properties
    let start: GridCoord
    let end: GridCoord
    let cellSize: CGFloat
    let color: Color
    var dashedOutline: Color?

    // MARK: - Body
    var body: some View {
        let startCenter = cellCenter(start)
        let endCenter = cellCenter(end)
        let dx = endCenter.x - startCenter.x
        let dy = endCenter.y - startCenter.y
        let length = sqrt(dx * dx + dy * dy) + cellSize * 0.85
        let angle = atan2(dy, dx)
        let midpoint = CGPoint(
            x: (startCenter.x + endCenter.x) / 2,
            y: (startCenter.y + endCenter.y) / 2
        )

        Capsule()
            .fill(color)
            .overlay {
                if let dashedOutline {
                    Capsule().strokeBorder(dashedOutline, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                }
            }
            .frame(width: length, height: cellSize * 0.75)
            .rotationEffect(.radians(angle))
            .position(midpoint)
            .allowsHitTesting(false)
    }
}

// MARK: - Helpers
private extension WordSearchCapsule {
    func cellCenter(_ coord: GridCoord) -> CGPoint {
        CGPoint(
            x: CGFloat(coord.col) * cellSize + cellSize / 2,
            y: CGFloat(coord.row) * cellSize + cellSize / 2
        )
    }
}
