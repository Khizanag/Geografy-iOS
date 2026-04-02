import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public enum MapColorPalette {
    public static func assignColors(to shapes: inout [CountryShape]) {
        let adjacency = buildAdjacencyMap(from: shapes)
        let colors = DesignSystem.Color.mapColors
        var assigned: [String: Int] = [:]
        var colorUsageCount = [Int: Int]()

        // Collect unique codes preserving first-occurrence order
        var seen = Set<String>()
        var codes = [String]()
        for shape in shapes where seen.insert(shape.id).inserted {
            codes.append(shape.id)
        }

        // Welsh-Powell: process high-degree countries first for optimal coloring,
        // then alphabetically for determinism across runs.
        let sortedCodes = codes.sorted { a, b in
            let degreeA = adjacency[a]?.count ?? 0
            let degreeB = adjacency[b]?.count ?? 0
            if degreeA != degreeB { return degreeA > degreeB }
            return a < b
        }

        for code in sortedCodes {
            let usedByNeighbors = neighborColors(for: code, adjacency: adjacency, assigned: assigned)
            let colorIndex = leastUsedAvailableColor(
                excluding: usedByNeighbors,
                totalColors: colors.count,
                usageCounts: colorUsageCount
            )
            assigned[code] = colorIndex
            colorUsageCount[colorIndex, default: 0] += 1
        }

        for i in shapes.indices {
            if let colorIndex = assigned[shapes[i].id] {
                shapes[i].color = colors[colorIndex]
            }
        }
    }
}

// MARK: - Adjacency Detection
private extension MapColorPalette {
    static func buildAdjacencyMap(from shapes: [CountryShape]) -> [String: Set<String>] {
        var adjacency: [String: Set<String>] = [:]

        for i in shapes.indices {
            for j in (i + 1)..<shapes.count {
                guard shapes[i].boundingBox.intersects(shapes[j].boundingBox.insetBy(dx: -20, dy: -20)) else {
                    continue
                }

                if shapesAreAdjacent(shapes[i], shapes[j]) {
                    adjacency[shapes[i].id, default: []].insert(shapes[j].id)
                    adjacency[shapes[j].id, default: []].insert(shapes[i].id)
                }
            }
        }

        // Hardcoded adjacencies for enclaves and very small countries
        // that geometry-based detection may miss
        addAdjacency("LS", "ZA", to: &adjacency) // Lesotho inside South Africa
        addAdjacency("SZ", "ZA", to: &adjacency) // Eswatini near South Africa
        addAdjacency("GM", "SN", to: &adjacency) // Gambia inside Senegal
        addAdjacency("VA", "IT", to: &adjacency) // Vatican inside Italy
        addAdjacency("SM", "IT", to: &adjacency) // San Marino inside Italy

        return adjacency
    }

    // Checks adjacency by sampling boundary points from each path and testing
    // if any point lies within the expanded bounding box of the opposing path.
    // A tight 3px threshold filters out false positives from narrow straits.
    static func shapesAreAdjacent(_ a: CountryShape, _ b: CountryShape) -> Bool {
        let threshold: CGFloat = 3.0

        for pathA in a.polygons {
            for pathB in b.polygons {
                let boxA = pathA.boundingBoxOfPath
                let boxB = pathB.boundingBoxOfPath

                guard boxA.insetBy(dx: -threshold * 4, dy: -threshold * 4).intersects(boxB) else {
                    continue
                }

                let expandedB = boxB.insetBy(dx: -threshold, dy: -threshold)
                if sampledPoints(from: pathA).contains(where: { expandedB.contains($0) }) {
                    return true
                }

                let expandedA = boxA.insetBy(dx: -threshold, dy: -threshold)
                if sampledPoints(from: pathB).contains(where: { expandedA.contains($0) }) {
                    return true
                }
            }
        }
        return false
    }

    static func sampledPoints(from path: CGPath, maxPoints: Int = 40) -> [CGPoint] {
        var allPoints = [CGPoint]()
        path.applyWithBlock { elementPtr in
            switch elementPtr.pointee.type {
            case .moveToPoint, .addLineToPoint:
                allPoints.append(elementPtr.pointee.points[0])
            case .addQuadCurveToPoint:
                allPoints.append(elementPtr.pointee.points[1])
            case .addCurveToPoint:
                allPoints.append(elementPtr.pointee.points[2])
            default:
                break
            }
        }
        guard allPoints.count > maxPoints else { return allPoints }
        let step = allPoints.count / maxPoints
        return (0..<maxPoints).map { allPoints[$0 * step] }
    }

    static func addAdjacency(_ a: String, _ b: String, to adjacency: inout [String: Set<String>]) {
        adjacency[a, default: []].insert(b)
        adjacency[b, default: []].insert(a)
    }
}

// MARK: - Color Assignment
private extension MapColorPalette {
    static func neighborColors(
        for code: String,
        adjacency: [String: Set<String>],
        assigned: [String: Int]
    ) -> Set<Int> {
        guard let neighbors = adjacency[code] else { return [] }
        var usedColors = Set<Int>()
        for neighbor in neighbors {
            if let colorIndex = assigned[neighbor] {
                usedColors.insert(colorIndex)
            }
        }
        return usedColors
    }

    // Picks the available color used least often globally, so isolated
    // countries (islands) spread evenly across the palette instead of
    // all clustering on index 0.
    static func leastUsedAvailableColor(
        excluding used: Set<Int>,
        totalColors: Int,
        usageCounts: [Int: Int]
    ) -> Int {
        var bestIndex = -1
        var lowestUsage = Int.max
        for i in 0..<totalColors {
            guard !used.contains(i) else { continue }
            let usage = usageCounts[i] ?? 0
            if usage < lowestUsage {
                lowestUsage = usage
                bestIndex = i
            }
        }
        return bestIndex >= 0 ? bestIndex : 0
    }
}
