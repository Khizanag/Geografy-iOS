import CoreGraphics
import SwiftUI

public struct CountryShape: Identifiable, @unchecked Sendable {
    public let id: String
    public var name: String
    public let continent: String
    public let polygons: [CGPath]
    public let centroid: CGPoint
    public let boundingBox: CGRect
    public var color: Color

    public init(
        id: String,
        name: String,
        continent: String,
        polygons: [CGPath],
        centroid: CGPoint,
        boundingBox: CGRect,
        color: Color
    ) {
        self.id = id
        self.name = name
        self.continent = continent
        self.polygons = polygons
        self.centroid = centroid
        self.boundingBox = boundingBox
        self.color = color
    }
}
