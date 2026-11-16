import CoreGraphics
import Geografy_Core_Common

/// Which countries touch and which sit close across water, worked out once per map for coloring it.
public struct MapAdjacency: Codable, Sendable {
    /// Countries sharing a land border.
    public let neighbors: [String: Set<String>]
    /// Countries that don't touch but lie a short crossing apart, such as island neighbors or coasts
    /// across a strait, where the same color would read as one country.
    public let nearby: [String: Set<String>]

    public init(neighbors: [String: Set<String>], nearby: [String: Set<String>] = [:]) {
        self.neighbors = neighbors
        self.nearby = nearby
    }
}

// MARK: - Building
public extension MapAdjacency {
    /// How close, in map points, two coasts must be to count as nearby: about 3° of longitude.
    static let nearbyDistance: CGFloat = 18

    /// From the outlines, joined with the land-border data, which catches borders too short to see.
    static func build(from shapes: [CountryShape]) -> MapAdjacency {
        var neighbors = geometricNeighbors(of: shapes)
        let codes = Set(shapes.map(\.id))
        for (code, borders) in CountryNeighbors.data where codes.contains(code) {
            for border in borders where codes.contains(border) {
                neighbors[code, default: []].insert(border)
                neighbors[border, default: []].insert(code)
            }
        }
        for (enclave, surrounding) in Self.enclaves {
            neighbors[enclave, default: []].insert(surrounding)
            neighbors[surrounding, default: []].insert(enclave)
        }
        let nearby = nearbyCountries(of: shapes, excluding: neighbors)
        return MapAdjacency(neighbors: neighbors, nearby: nearby)
    }
}

// MARK: - Touching
private extension MapAdjacency {
    /// Enclaves and tiny states the outline check can miss.
    static let enclaves: [(String, String)] = [("LS", "ZA"), ("SZ", "ZA"), ("GM", "SN"), ("VA", "IT"), ("SM", "IT")]

    /// One polygon's bounds and boundary samples, worked out once rather than for every pair it's compared in.
    struct PolygonOutline {
        let bounds: CGRect
        let samples: [CGPoint]
    }

    static func geometricNeighbors(of shapes: [CountryShape]) -> [String: Set<String>] {
        var neighbors: [String: Set<String>] = [:]
        let outlines = shapes.map { shape in
            shape.polygons.map { PolygonOutline(bounds: $0.boundingBoxOfPath, samples: sampledPoints(from: $0)) }
        }
        for first in shapes.indices {
            for second in (first + 1)..<shapes.count where shapes[first].id != shapes[second].id {
                guard shapes[first].boundingBox.intersects(shapes[second].boundingBox.insetBy(dx: -20, dy: -20)),
                      outlinesTouch(outlines[first], outlines[second]) else { continue }
                neighbors[shapes[first].id, default: []].insert(shapes[second].id)
                neighbors[shapes[second].id, default: []].insert(shapes[first].id)
            }
        }
        return neighbors
    }

    /// Whether a boundary sample of either outline lies within a hair of the other's bounds: tight enough
    /// that a narrow strait doesn't count as a border.
    static func outlinesTouch(_ outlines: [PolygonOutline], _ otherOutlines: [PolygonOutline]) -> Bool {
        let threshold: CGFloat = 3
        for outline in outlines {
            let near = outline.bounds.insetBy(dx: -threshold * 4, dy: -threshold * 4)
            let expanded = outline.bounds.insetBy(dx: -threshold, dy: -threshold)
            for other in otherOutlines where near.intersects(other.bounds) {
                let otherExpanded = other.bounds.insetBy(dx: -threshold, dy: -threshold)
                if outline.samples.contains(where: { otherExpanded.contains($0) }) { return true }
                if other.samples.contains(where: { expanded.contains($0) }) { return true }
            }
        }
        return false
    }

    static func sampledPoints(from path: CGPath, maxPoints: Int = 40) -> [CGPoint] {
        var points = [CGPoint]()
        path.applyWithBlock { element in
            switch element.pointee.type {
            case .moveToPoint, .addLineToPoint: points.append(element.pointee.points[0])
            case .addQuadCurveToPoint: points.append(element.pointee.points[1])
            case .addCurveToPoint: points.append(element.pointee.points[2])
            default: break
            }
        }
        guard points.count > maxPoints else { return points }
        let step = points.count / maxPoints
        return (0..<maxPoints).map { points[$0 * step] }
    }
}

// MARK: - Nearby
private extension MapAdjacency {
    /// Countries whose coasts come within `nearbyDistance`, found with a grid of that size so each sample
    /// is only compared with samples in its own and adjoining cells.
    static func nearbyCountries(
        of shapes: [CountryShape],
        excluding neighbors: [String: Set<String>]
    ) -> [String: Set<String>] {
        let cellSize = nearbyDistance
        var grid: [GridCell: [(code: String, point: CGPoint)]] = [:]
        for shape in shapes {
            for polygon in shape.polygons {
                for point in sampledPoints(from: polygon, maxPoints: 24) {
                    grid[GridCell(point, size: cellSize), default: []].append((shape.id, point))
                }
            }
        }

        var nearby: [String: Set<String>] = [:]
        for (cell, entries) in grid {
            let around = cell.surrounding.flatMap { grid[$0] ?? [] }
            for entry in entries {
                for other in around where other.code != entry.code {
                    guard hypot(other.point.x - entry.point.x, other.point.y - entry.point.y) <= nearbyDistance,
                          neighbors[entry.code]?.contains(other.code) != true else { continue }
                    nearby[entry.code, default: []].insert(other.code)
                }
            }
        }
        return nearby
    }

    struct GridCell: Hashable {
        let column: Int
        let row: Int

        init(column: Int, row: Int) {
            self.column = column
            self.row = row
        }

        init(_ point: CGPoint, size: CGFloat) {
            self.init(column: Int((point.x / size).rounded(.down)), row: Int((point.y / size).rounded(.down)))
        }

        var surrounding: [GridCell] {
            (-1...1).flatMap { columnStep in
                (-1...1).map { rowStep in GridCell(column: column + columnStep, row: row + rowStep) }
            }
        }
    }
}
