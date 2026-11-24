import Geografy_Core_DesignSystem
import SwiftUI

/// Owns the drag so each move redraws only the live highlight; the puzzle hears about a selection once it ends.
struct WordSearchSelectionLayer: View {
    // MARK: - Properties
    let gridSize: Int
    let cellSize: CGFloat
    let isEnabled: Bool
    let onSelect: (GridCoord, GridCoord) -> Void

    @State private var selectionStart: GridCoord?
    @State private var selectionEnd: GridCoord?

    // MARK: - Body
    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .overlay { selectionCapsule }
            #if !os(tvOS)
            .gesture(isEnabled ? dragGesture : nil)
            #endif
            .accessibilityHidden(true)
    }
}

// MARK: - Subviews
private extension WordSearchSelectionLayer {
    @ViewBuilder
    var selectionCapsule: some View {
        if let selectionStart, let selectionEnd {
            WordSearchCapsule(
                start: selectionStart,
                end: selectionEnd,
                cellSize: cellSize,
                color: DesignSystem.Color.accent.opacity(DesignSystem.Opacity.half)
            )
        }
    }
}

#if !os(tvOS)
// MARK: - Gesture
private extension WordSearchSelectionLayer {
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let start = selectionStart ?? clampedCoord(at: value.startLocation)
                if selectionStart == nil {
                    selectionStart = start
                }
                let end = GridCoord.snappedEnd(
                    from: start,
                    offset: offset(of: value.location, from: start),
                    gridSize: gridSize
                )
                if selectionEnd != end {
                    selectionEnd = end
                }
            }
            .onEnded { _ in
                if let selectionStart, let selectionEnd {
                    onSelect(selectionStart, selectionEnd)
                }
                selectionStart = nil
                selectionEnd = nil
            }
    }

    /// How far `location` is from the center of `cell`, in cells.
    func offset(of location: CGPoint, from cell: GridCoord) -> CGVector {
        CGVector(
            dx: location.x / cellSize - (CGFloat(cell.col) + 0.5),
            dy: location.y / cellSize - (CGFloat(cell.row) + 0.5)
        )
    }

        func clampedCoord(at location: CGPoint) -> GridCoord {
        let row = Int(location.y / cellSize)
        let col = Int(location.x / cellSize)
        return GridCoord(
            row: max(0, min(gridSize - 1, row)),
            col: max(0, min(gridSize - 1, col))
        )
    }
}
#endif
