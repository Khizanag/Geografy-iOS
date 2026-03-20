import SwiftUI

enum MapColorPalette {
    static func assignColors(to shapes: inout [CountryShape]) {
        let adjacency = buildAdjacencyMap(from: shapes)
        let colors = GeoColors.mapColors
        var assigned: [String: Int] = [:]

        let sortedIndices = shapes.indices.sorted { shapes[$0].name < shapes[$1].name }

        for i in sortedIndices {
            let code = shapes[i].id
            let neighborColorIndices = neighborColors(for: code, adjacency: adjacency, assigned: assigned)
            let colorIndex = firstAvailableColor(excluding: neighborColorIndices, totalColors: colors.count)

            assigned[code] = colorIndex
            shapes[i].color = colors[colorIndex]
        }
    }
}

// MARK: - Adjacency Detection

private extension MapColorPalette {
    static func buildAdjacencyMap(from shapes: [CountryShape]) -> [String: Set<String>] {
        var adjacency: [String: Set<String>] = [:]

        for i in shapes.indices {
            for j in (i + 1)..<shapes.count {
                guard shapes[i].boundingBox.intersects(shapes[j].boundingBox.insetBy(dx: -5, dy: -5)) else {
                    continue
                }

                if shapesAreAdjacent(shapes[i], shapes[j]) {
                    adjacency[shapes[i].id, default: []].insert(shapes[j].id)
                    adjacency[shapes[j].id, default: []].insert(shapes[i].id)
                }
            }
        }

        // Hardcoded adjacencies for enclaves and edge cases
        addAdjacency("LS", "ZA", to: &adjacency) // Lesotho inside South Africa
        addAdjacency("SZ", "ZA", to: &adjacency) // Eswatini near South Africa
        addAdjacency("GM", "SN", to: &adjacency) // Gambia inside Senegal
        addAdjacency("VA", "IT", to: &adjacency) // Vatican inside Italy
        addAdjacency("SM", "IT", to: &adjacency) // San Marino inside Italy

        return adjacency
    }

    static func shapesAreAdjacent(_ a: CountryShape, _ b: CountryShape) -> Bool {
        for pathA in a.polygons {
            for pathB in b.polygons {
                let boxA = pathA.boundingBoxOfPath
                let boxB = pathB.boundingBoxOfPath
                let threshold: CGFloat = 3

                let expanded = boxA.insetBy(dx: -threshold, dy: -threshold)
                if expanded.intersects(boxB) {
                    return true
                }
            }
        }
        return false
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

    static func firstAvailableColor(excluding used: Set<Int>, totalColors: Int) -> Int {
        for i in 0..<totalColors {
            if !used.contains(i) {
                return i
            }
        }
        return 0
    }
}
