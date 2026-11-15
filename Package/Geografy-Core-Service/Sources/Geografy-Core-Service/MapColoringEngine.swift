import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// Colors the countries of a map from a `MapPalette` so that the map reads at a glance.
///
/// It's graph coloring, the way atlases are colored, with the palette's own contrast in the loop:
/// 1. **Borders** come from the outlines, and from the land-border data for borders too short to see.
/// 2. **Order** follows DSatur: the country whose neighbors already use the most colors goes next,
///    so the hardest corners are settled while choices remain.
/// 3. **Choice**: never a color a neighbor has. Of those left, one that looks different enough from the
///    neighbors' colors, then one not used by countries a short sea crossing away, then one not used two
///    borders out, and finally the one used least, so the colors spread evenly over the map.
///    "Different enough" is the palette's typical spacing: past it, more contrast isn't chased, or the same
///    two most different colors would repeat across the map like a checkerboard.
///
/// The result depends only on the map and the palette, so every map and every launch match.
public enum MapColoringEngine {
    /// Each country's index into the palette.
    public static func assign(codes: [String], adjacency: MapAdjacency, distances: [[Double]]) -> [String: Int] {
        let colorCount = distances.count
        guard colorCount > 0 else { return [:] }

        var assigned: [String: Int] = [:]
        var usage = [Int](repeating: 0, count: colorCount)
        var remaining = Set(codes)
        let enoughContrast = typicalSpacing(of: distances)

        while let code = nextCountry(in: remaining, adjacency: adjacency, assigned: assigned) {
            let color = bestColor(
                for: code,
                adjacency: adjacency,
                assigned: assigned,
                usage: usage,
                distances: distances,
                enoughContrast: enoughContrast
            )
            assigned[code] = color
            usage[color] += 1
            remaining.remove(code)
        }
        return assigned
    }

    /// `shapes` filled from `palette`, keeping their outlines.
    public static func colored(
        _ shapes: [CountryShape],
        adjacency: MapAdjacency,
        palette: MapPalette
    ) -> [CountryShape] {
        let codes = Array(Set(shapes.map(\.id))).sorted()
        let assignment = assign(codes: codes, adjacency: adjacency, distances: palette.distances)
        let colors = palette.colors
        return shapes.map { shape in
            shape.recolored(colors[assignment[shape.id] ?? 0])
        }
    }
}

// MARK: - Order
private extension MapColoringEngine {
    /// DSatur's pick: the most distinct neighbor colors, then the most neighbors, then the most nearby
    /// countries, then the code, so the order never varies.
    static func nextCountry(
        in remaining: Set<String>,
        adjacency: MapAdjacency,
        assigned: [String: Int]
    ) -> String? {
        remaining.max { first, second in
            let firstKey = priority(of: first, adjacency: adjacency, assigned: assigned)
            let secondKey = priority(of: second, adjacency: adjacency, assigned: assigned)
            if firstKey != secondKey { return firstKey.lexicographicallyPrecedes(secondKey) }
            return first > second
        }
    }

    static func priority(of code: String, adjacency: MapAdjacency, assigned: [String: Int]) -> [Int] {
        let neighbors = adjacency.neighbors[code] ?? []
        let saturation = Set(neighbors.compactMap { assigned[$0] }).count
        return [saturation, neighbors.count, adjacency.nearby[code]?.count ?? 0]
    }
}

// MARK: - Choice
private extension MapColoringEngine {
    static func bestColor(
        for code: String,
        adjacency: MapAdjacency,
        assigned: [String: Int],
        usage: [Int],
        distances: [[Double]],
        enoughContrast: Double
    ) -> Int {
        let colorCount = distances.count
        let neighborColors = (adjacency.neighbors[code] ?? []).compactMap { assigned[$0] }
        let nearbyColors = (adjacency.nearby[code] ?? []).compactMap { assigned[$0] }
        let secondRingColors = secondRing(of: code, adjacency: adjacency).compactMap { assigned[$0] }

        let free = (0..<colorCount).filter { !neighborColors.contains($0) }
        let candidates = free.isEmpty ? Array(0..<colorCount) : free
        // Compared with the colors close by: neighbors first, or the nearby coasts for an island.
        let contrastColors = neighborColors.isEmpty ? nearbyColors : neighborColors

        return candidates.min { first, second in
            let context = ScoreContext(
                contrastColors: contrastColors,
                nearbyColors: nearbyColors,
                secondRingColors: secondRingColors,
                usage: usage,
                distances: distances,
                enoughContrast: enoughContrast
            )
            let firstScore = context.score(first)
            let secondScore = context.score(second)
            if firstScore != secondScore { return firstScore.lexicographicallyPrecedes(secondScore) }
            return first < second
        } ?? 0
    }

    /// What a color is weighed against, for one country.
    struct ScoreContext {
        let contrastColors: [Int]
        let nearbyColors: [Int]
        let secondRingColors: [Int]
        let usage: [Int]
        let distances: [[Double]]
        let enoughContrast: Double

        /// Lower is better: contrast short of enough, then repeats across the sea, then two borders out,
        /// then how often the color is used already.
        func score(_ color: Int) -> [Int] {
            let contrast = contrastColors.map { distances[color][$0] }.min() ?? enoughContrast
            return [
                Int(((enoughContrast - min(contrast, enoughContrast)) * 100).rounded()),
                nearbyColors.count { $0 == color },
                secondRingColors.count { $0 == color },
                usage[color],
            ]
        }
    }

    /// The palette's typical gap between two colors: its pair distances' lower third.
    static func typicalSpacing(of distances: [[Double]]) -> Double {
        var pairs: [Double] = []
        for row in distances.indices {
            for column in distances.indices where column > row {
                pairs.append(distances[row][column])
            }
        }
        pairs.sort()
        guard !pairs.isEmpty else { return 0 }
        return pairs[pairs.count / 3]
    }

    /// The neighbors' neighbors, other than the country itself and its own neighbors.
    static func secondRing(of code: String, adjacency: MapAdjacency) -> Set<String> {
        let neighbors = adjacency.neighbors[code] ?? []
        var ring = Set<String>()
        for neighbor in neighbors {
            ring.formUnion(adjacency.neighbors[neighbor] ?? [])
        }
        return ring.subtracting(neighbors).subtracting([code])
    }
}
