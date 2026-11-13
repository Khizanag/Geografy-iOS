import Geografy_Core_Common

extension WordSearchDirection {
    var spokenDescription: String {
        switch self {
        case .horizontal: "left to right"
        case .horizontalReverse: "right to left"
        case .vertical: "top to bottom"
        case .verticalReverse: "bottom to top"
        case .diagonalDown: "diagonally down and right"
        case .diagonalUp: "diagonally up and right"
        }
    }
}

extension WordSearchWord {
    /// Where the word sits, with 1-based row and column numbers to match the grid's row labels.
    var spokenLocation: String {
        "starts at row \(startRow + 1), column \(startCol + 1), reading \(direction.spokenDescription)"
    }
}
