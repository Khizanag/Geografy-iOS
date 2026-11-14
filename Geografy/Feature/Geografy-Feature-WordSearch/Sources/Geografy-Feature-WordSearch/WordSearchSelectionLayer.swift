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
                color: DesignSystem.Color.accent.opacity(0.5)
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
                let coord = clampedCoord(at: value.location)
                if selectionStart == nil {
                    selectionStart = coord
                }
                if selectionEnd != coord {
                    selectionEnd = coord
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
