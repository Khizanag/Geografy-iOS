import CoreGraphics
import SwiftUI

public struct CountryShape: Identifiable, @unchecked Sendable {
    public let id: String
    public var name: String
    public let continent: String
    public let polygons: [CGPath]
    /// The whole outline as one path at a few levels of detail, coarsest first; see `detailPath(forScale:)`.
    public let detailPaths: [CGPath]
    public let centroid: CGPoint
    public let boundingBox: CGRect
    public var color: Color

    /// The largest map scale at which each entry of `detailPaths` stays within a fraction of a point of the border.
    public static let detailScaleLimits: [CGFloat] = [0.5, 2, 8, .infinity]

    public init(
        id: String,
        name: String,
        continent: String,
        polygons: [CGPath],
        detailPaths: [CGPath] = [],
        centroid: CGPoint,
        boundingBox: CGRect,
        color: Color
    ) {
        self.id = id
        self.name = name
        self.continent = continent
        self.polygons = polygons
        self.detailPaths = detailPaths
        self.centroid = centroid
        self.boundingBox = boundingBox
        self.color = color
    }

    /// The outline simplified for drawing at `scale`: a zoomed-out map draws a few thousand points
    /// per frame instead of the full half a million. Nil when the shape has no detail levels.
    public func detailPath(forScale scale: CGFloat) -> CGPath? {
        guard !detailPaths.isEmpty else { return nil }
        let level = Self.detailScaleLimits.firstIndex { scale <= $0 } ?? detailPaths.count - 1
        return detailPaths[min(level, detailPaths.count - 1)]
    }

    /// Whether the point, in map coordinates, falls inside the country; checks the bounding box first.
    public func contains(_ point: CGPoint) -> Bool {
        guard boundingBox.contains(point) else { return false }
        return polygons.contains { $0.boundingBoxOfPath.contains(point) && $0.contains(point) }
    }

    /// The same country in another color, keeping its detail levels.
    public func recolored(_ color: Color) -> CountryShape {
        var shape = self
        shape.color = color
        return shape
    }
}
