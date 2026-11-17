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
