import SwiftUI

struct GridCoord: Hashable, Sendable {
    let row: Int
    let col: Int
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
