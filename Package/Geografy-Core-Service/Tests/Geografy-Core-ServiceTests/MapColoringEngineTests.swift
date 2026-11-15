import Geografy_Core_DesignSystem
@testable import Geografy_Core_Service
import Testing

@Suite("MapColoringEngine")
struct MapColoringEngineTests {
    /// A palette where colors 0 and 1 are near twins and the rest are far apart.
    private let twinPalette: [[Double]] = (0..<6).map { row in
        (0..<6).map { column in
            if row == column { return 0 }
            return Set([row, column]) == [0, 1] ? 0.01 : 0.2
        }
    }

    /// A 6×6 grid of countries, each touching the ones beside, above, and below it.
    private func grid(size: Int = 6) -> (codes: [String], adjacency: MapAdjacency) {
        var neighbors: [String: Set<String>] = [:]
        let code = { (row: Int, column: Int) in "R\(row)C\(column)" }
        for row in 0..<size {
            for column in 0..<size {
                var touching = Set<String>()
                if row > 0 { touching.insert(code(row - 1, column)) }
                if row < size - 1 { touching.insert(code(row + 1, column)) }
                if column > 0 { touching.insert(code(row, column - 1)) }
                if column < size - 1 { touching.insert(code(row, column + 1)) }
                neighbors[code(row, column)] = touching
            }
        }
        return (neighbors.keys.sorted(), MapAdjacency(neighbors: neighbors))
    }

    @Test("Countries that share a border never share a color", arguments: MapPalette.allCases)
    func neighborsDiffer(palette: MapPalette) {
        let (codes, adjacency) = grid()
        let assignment = MapColoringEngine.assign(codes: codes, adjacency: adjacency, distances: palette.distances)

        #expect(assignment.count == codes.count)
        for (code, neighbors) in adjacency.neighbors {
            for neighbor in neighbors {
                #expect(assignment[code] != assignment[neighbor])
            }
        }
    }

    @Test("A wheel of countries around a hub, the hard case for few colors, still gets a proper coloring")
    func wheel() {
        let rim = (0..<7).map { "W\($0)" }
        var neighbors: [String: Set<String>] = ["HUB": Set(rim)]
        for (index, code) in rim.enumerated() {
            neighbors[code] = ["HUB", rim[(index + 1) % rim.count], rim[(index + rim.count - 1) % rim.count]]
        }
        let adjacency = MapAdjacency(neighbors: neighbors)
        let assignment = MapColoringEngine.assign(
            codes: ["HUB"] + rim, adjacency: adjacency, distances: MapPalette.atlas.distances
        )

        for (code, touching) in neighbors {
            for neighbor in touching {
                #expect(assignment[code] != assignment[neighbor])
            }
        }
    }

    @Test("Neighbors never get colors that look alike when better ones are free")
    func avoidsLookAlikes() {
        let (codes, adjacency) = grid()
        let assignment = MapColoringEngine.assign(codes: codes, adjacency: adjacency, distances: twinPalette)

        for (code, neighbors) in adjacency.neighbors {
            for neighbor in neighbors {
                let pair = Set([assignment[code], assignment[neighbor]])
                #expect(pair != [0, 1])
            }
        }
    }

    @Test("Countries across a short stretch of sea get different colors too")
    func nearbyDiffer() {
        let adjacency = MapAdjacency(neighbors: [:], nearby: ["A": ["B"], "B": ["A"]])
        let assignment = MapColoringEngine.assign(
            codes: ["A", "B"], adjacency: adjacency, distances: MapPalette.vivid.distances
        )
        #expect(assignment["A"] != assignment["B"])
    }

    @Test("Colors spread evenly instead of piling onto a few")
    func balanced() {
        let (codes, adjacency) = grid()
        let assignment = MapColoringEngine.assign(
            codes: codes, adjacency: adjacency, distances: MapPalette.atlas.distances
        )
        let counts = Dictionary(grouping: assignment.values, by: { $0 }).mapValues(\.count)

        #expect(counts.count >= 4)
        #expect((counts.values.max() ?? 0) - (counts.values.min() ?? 0) <= 6)
    }

    @Test("The same map and palette always color the same way")
    func deterministic() {
        let (codes, adjacency) = grid()
        let first = MapColoringEngine.assign(codes: codes, adjacency: adjacency, distances: MapPalette.earth.distances)
        let second = MapColoringEngine.assign(
            codes: codes.reversed(), adjacency: adjacency, distances: MapPalette.earth.distances
        )
        #expect(first == second)
    }
}
