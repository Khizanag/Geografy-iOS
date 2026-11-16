import Geografy_Core_DesignSystem
import SwiftUI

/// The static letters. Equatable on the puzzle and cell size, so found words, hints and drags skip its 144 cells.
struct WordSearchLetterGrid: View, Equatable {
    // MARK: - Properties
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    let puzzleID: UUID
    let grid: [[Character]]
    /// Each row's letters as VoiceOver reads them, built once per puzzle.
    let spokenRows: [String]
    let cellSize: CGFloat

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            ForEach(grid.indices, id: \.self) { row in
                // Each row reads as one element, so VoiceOver can scan the grid line by line.
                HStack(spacing: 0) {
                    ForEach(grid[row].indices, id: \.self) { col in
                        cell(letter: grid[row][col])
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Row \(row + 1)")
                .accessibilityValue(spokenRows[row])
            }
        }
    }

    // MARK: - Equatable
    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.puzzleID == rhs.puzzleID && lhs.cellSize == rhs.cellSize
    }
}

// MARK: - Subviews
private extension WordSearchLetterGrid {
    func cell(letter: Character) -> some View {
        Text(String(letter))
            .font(DesignSystem.Font.system(size: max(cellSize * 0.48, 12), weight: .semibold, design: .monospaced))
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(width: cellSize, height: cellSize)
            .background(DesignSystem.Color.cardBackground.opacity(reduceTransparency ? 1 : 0.3))
            .border(contrast == .increased ? DesignSystem.Color.dividerSubtle : .clear, width: 0.5)
    }
}

// MARK: - Spoken Rows
extension WordSearchLetterGrid {
    static func spokenRows(of grid: [[Character]]) -> [String] {
        grid.map { $0.map(String.init).joined(separator: " ") }
    }
}
