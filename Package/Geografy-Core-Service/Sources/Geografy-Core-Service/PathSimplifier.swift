import CoreGraphics

/// Douglas–Peucker simplification of the map's country outlines.
enum PathSimplifier {
    /// The ring with every point dropped that lies within `tolerance` of the simplified outline.
    /// Returns fewer than three points when the ring is too small to show at that tolerance.
    static func simplify(ring: [CGPoint], tolerance: CGFloat) -> [CGPoint] {
        guard ring.count > 3 else { return ring }

        // A closed ring starts and ends on the same point, so split it at the point farthest from
        // the start and simplify the two halves as open lines.
        let start = ring[0]
        var farthest = 0
        var farthestDistance: CGFloat = 0
        for index in ring.indices {
            let distance = squaredDistance(ring[index], start)
            if distance > farthestDistance {
                farthestDistance = distance
                farthest = index
            }
        }
        guard farthest > 0 else { return [start] }

        var keeps = [Bool](repeating: false, count: ring.count)
        keeps[0] = true
        keeps[farthest] = true
        keeps[ring.count - 1] = true
        markKept(in: ring, from: 0, to: farthest, squaredTolerance: tolerance * tolerance, keeps: &keeps)
        markKept(in: ring, from: farthest, to: ring.count - 1, squaredTolerance: tolerance * tolerance, keeps: &keeps)

        return ring.indices.compactMap { keeps[$0] ? ring[$0] : nil }
    }

    /// One closed path holding every ring.
    static func makePath(rings: [[CGPoint]]) -> CGPath {
        let path = CGMutablePath()
        for ring in rings where ring.count >= 3 {
            path.addLines(between: ring)
            path.closeSubpath()
        }
        return path
    }
}

// MARK: - Helpers
private extension PathSimplifier {
    static func markKept(
        in points: [CGPoint],
        from first: Int,
        to last: Int,
        squaredTolerance: CGFloat,
        keeps: inout [Bool]
    ) {
        var segments = [(first, last)]
        while let (start, end) = segments.popLast() {
            guard end > start + 1 else { continue }
            var farthest = start
            var farthestDistance: CGFloat = 0
            for index in (start + 1)..<end {
                let distance = squaredDistance(points[index], toSegmentFrom: points[start], to: points[end])
                if distance > farthestDistance {
                    farthestDistance = distance
                    farthest = index
                }
            }
            guard farthestDistance > squaredTolerance else { continue }
            keeps[farthest] = true
            segments.append((start, farthest))
            segments.append((farthest, end))
        }
    }

    static func squaredDistance(_ point: CGPoint, _ other: CGPoint) -> CGFloat {
        let deltaX = point.x - other.x
        let deltaY = point.y - other.y
        return deltaX * deltaX + deltaY * deltaY
    }

    static func squaredDistance(_ point: CGPoint, toSegmentFrom start: CGPoint, to end: CGPoint) -> CGFloat {
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        let lengthSquared = deltaX * deltaX + deltaY * deltaY
        guard lengthSquared > 0 else { return squaredDistance(point, start) }
        let projection = ((point.x - start.x) * deltaX + (point.y - start.y) * deltaY) / lengthSquared
        let clamped = min(max(projection, 0), 1)
        return squaredDistance(point, CGPoint(x: start.x + clamped * deltaX, y: start.y + clamped * deltaY))
    }
}
