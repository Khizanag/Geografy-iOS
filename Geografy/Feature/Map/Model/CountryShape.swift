import CoreGraphics
import SwiftUI

struct CountryShape: Identifiable, @unchecked Sendable {
    let id: String
    let name: String
    let continent: String
    let polygons: [CGPath]
    let centroid: CGPoint
    let boundingBox: CGRect
    var color: Color
}
