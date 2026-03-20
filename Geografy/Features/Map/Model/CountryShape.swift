import CoreGraphics
import SwiftUI

struct CountryShape: Identifiable {
    let id: String
    let name: String
    let polygons: [CGPath]
    let centroid: CGPoint
    let boundingBox: CGRect
    var color: Color
}
