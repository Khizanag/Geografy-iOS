import CoreGraphics
import Geografy_Core_Common

// MARK: - Map Outline
public extension TravelStatus {
    /// Visited countries get a solid outline and want-to-visit ones a dashed one, so the two differ by shape too.
    func mapOutlineDash(lineWidth: CGFloat) -> [CGFloat] {
        switch self {
        case .visited: []
        case .wantToVisit: [lineWidth * 3, lineWidth * 2]
        }
    }

    var mapOutlineDescription: String {
        switch self {
        case .visited: "solid outline"
        case .wantToVisit: "dashed outline"
        }
    }
}
