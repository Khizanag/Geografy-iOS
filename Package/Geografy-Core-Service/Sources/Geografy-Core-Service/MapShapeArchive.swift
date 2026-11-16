import CoreGraphics
import Foundation
import Geografy_Core_Common

/// Parsed country outlines saved to disk, so the map opens on later launches without decoding the 13 MB GeoJSON
/// and rebuilding every outline. Points are written as raw `CGPoint` memory and copied back in one go, which
/// keeps reading fast even in an unoptimized build.
enum MapShapeArchive {
    /// Bumped whenever the layout below changes, so an old file is never misread.
    static let formatVersion: UInt32 = 1
    private static let magic: UInt32 = 0x4D41_5053 // "MAPS"

    // MARK: - Encoding
    static func encode(_ shapes: [CountryShape]) -> Data {
        var writer = Writer()
        writer.write(magic)
        writer.write(formatVersion)
        writer.write(UInt32(shapes.count))
        for shape in shapes {
            writer.write(shape.id)
            writer.write(shape.name)
            writer.write(shape.continent)
            writer.write([shape.centroid])
            writer.write([shape.boundingBox.origin, CGPoint(x: shape.boundingBox.width, y: shape.boundingBox.height)])
            writer.write(UInt32(shape.polygons.count))
            shape.polygons.forEach { writer.write($0) }
            // The most detailed level holds the same rings as the polygons, so it's rebuilt from them instead.
            let savedLevels = shape.detailPaths.dropLast()
            writer.write(UInt32(shape.detailPaths.count))
            savedLevels.forEach { writer.write($0) }
        }
        return writer.data
    }

    // MARK: - Decoding
    /// Nil when the data isn't a whole archive of this version.
    static func decode(_ data: Data) -> [CountryShape]? {
        var reader = Reader(data: data)
        guard reader.readUInt32() == magic, reader.readUInt32() == formatVersion,
              let count = reader.readUInt32() else { return nil }
        var shapes: [CountryShape] = []
        shapes.reserveCapacity(Int(count))
        for _ in 0..<count {
            guard let shape = reader.readShape() else { return nil }
            shapes.append(shape)
        }
        return reader.isAtEnd ? shapes : nil
    }
}

// MARK: - Writer
private struct Writer {
    var data = Data()

    mutating func write(_ value: UInt32) {
        withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
    }

    mutating func write(_ string: String) {
        let bytes = Data(string.utf8)
        write(UInt32(bytes.count))
        data.append(bytes)
    }

    mutating func write(_ points: [CGPoint]) {
        write(UInt32(points.count))
        points.withUnsafeBytes { data.append(contentsOf: $0) }
    }

    /// A path as its rings: every subpath's points, closed on reading.
    mutating func write(_ path: CGPath) {
        var rings: [[CGPoint]] = []
        path.applyWithBlock { element in
            let element = element.pointee
            switch element.type {
            case .moveToPoint:
                rings.append([element.points[0]])
            case .addLineToPoint:
                rings[rings.count - 1].append(element.points[0])
            case .addQuadCurveToPoint:
                rings[rings.count - 1].append(element.points[1])
            case .addCurveToPoint:
                rings[rings.count - 1].append(element.points[2])
            case .closeSubpath:
                break
            @unknown default:
                break
            }
        }
        write(UInt32(rings.count))
        rings.forEach { write($0) }
    }
}

// MARK: - Reader
private struct Reader {
    let data: Data
    var offset = 0

    var isAtEnd: Bool { offset == data.count }

    mutating func readUInt32() -> UInt32? {
        guard offset + 4 <= data.count else { return nil }
        let value = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: offset, as: UInt32.self) }
        offset += 4
        return UInt32(littleEndian: value)
    }

    mutating func readString() -> String? {
        guard let length = readUInt32().map(Int.init), offset + length <= data.count else { return nil }
        let bytes = data[data.startIndex + offset ..< data.startIndex + offset + length]
        offset += length
        return String(bytes: bytes, encoding: .utf8)
    }

    mutating func readPoints() -> [CGPoint]? {
        guard let count = readUInt32().map(Int.init) else { return nil }
        let byteCount = count * MemoryLayout<CGPoint>.stride
        guard offset + byteCount <= data.count else { return nil }
        let start = offset
        let points = [CGPoint](unsafeUninitializedCapacity: count) { buffer, initialized in
            data.withUnsafeBytes { bytes in
                UnsafeMutableRawBufferPointer(buffer).copyMemory(
                    from: UnsafeRawBufferPointer(rebasing: bytes[start ..< start + byteCount])
                )
            }
            initialized = count
        }
        offset += byteCount
        return points
    }

    mutating func readRings() -> [[CGPoint]]? {
        guard let count = readUInt32() else { return nil }
        var rings: [[CGPoint]] = []
        for _ in 0..<count {
            guard let ring = readPoints() else { return nil }
            rings.append(ring)
        }
        return rings
    }

    mutating func readPath() -> CGMutablePath? {
        guard let rings = readRings() else { return nil }
        let path = CGMutablePath()
        for ring in rings where !ring.isEmpty {
            path.addLines(between: ring)
            path.closeSubpath()
        }
        return path
    }

    mutating func readShape() -> CountryShape? {
        guard let id = readString(), let name = readString(), let continent = readString(),
              let centroid = readPoints()?.first,
              let box = readPoints(), box.count == 2,
              let polygonCount = readUInt32() else { return nil }
        var polygons: [CGPath] = []
        for _ in 0..<polygonCount {
            guard let polygon = readPath() else { return nil }
            polygons.append(polygon)
        }
        guard let levelCount = readUInt32() else { return nil }
        var levels: [CGPath] = []
        for _ in 0..<max(Int(levelCount) - 1, 0) {
            guard let level = readPath() else { return nil }
            levels.append(level)
        }
        if levelCount > 0 {
            let full = CGMutablePath()
            polygons.forEach { full.addPath($0) }
            levels.append(full)
        }
        return CountryShape(
            id: id,
            name: name,
            continent: continent,
            polygons: polygons,
            detailPaths: levels,
            centroid: centroid,
            boundingBox: CGRect(origin: box[0], size: CGSize(width: box[1].x, height: box[1].y)),
            color: .gray
        )
    }
}
