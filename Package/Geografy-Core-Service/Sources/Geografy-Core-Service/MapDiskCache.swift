import Foundation
import Geografy_Core_Common

/// Parsed outlines and borders kept between launches in the Caches folder, so only the first launch, or the first
/// after an update or a territorial-dispute change, parses the map. The system may clear Caches; the map is then
/// parsed again.
enum MapDiskCache {
    // MARK: - Key
    /// Changes whenever the saved data would differ: another build of the app, another map file, or another
    /// territorial-dispute choice.
    static func key() -> String {
        let fileManager = FileManager.default
        let executableDate = Bundle.main.executableURL
            .flatMap { try? fileManager.attributesOfItem(atPath: $0.path)[.modificationDate] as? Date }
            .map { String($0.timeIntervalSince1970) } ?? ""
        let mapSize = Bundle.main.url(forResource: "countries", withExtension: "geojson")
            .flatMap { try? fileManager.attributesOfItem(atPath: $0.path)[.size] as? Int }
            .map(String.init) ?? ""
        let parts = [
            String(MapShapeArchive.formatVersion),
            executableDate,
            mapSize,
            GeoJSONParser.territoryMergeKey(),
        ]
        return hexHash(parts.joined(separator: "|"))
    }

    // MARK: - Shapes
    static func loadShapes(projection: MapProjectionKind, key: String) -> [CountryShape]? {
        guard let url = shapesURL(projection: projection, key: key),
              let data = try? Data(contentsOf: url, options: .alwaysMapped) else { return nil }
        return MapShapeArchive.decode(data)
    }

    static func saveShapes(_ shapes: [CountryShape], projection: MapProjectionKind, key: String) {
        guard let url = shapesURL(projection: projection, key: key) else { return }
        write(MapShapeArchive.encode(shapes), to: url, key: key)
    }

    // MARK: - Adjacency
    static func loadAdjacency(key: String) -> MapAdjacency? {
        guard let url = adjacencyURL(key: key), let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(MapAdjacency.self, from: data)
    }

    static func saveAdjacency(_ adjacency: MapAdjacency, key: String) {
        guard let url = adjacencyURL(key: key), let data = try? JSONEncoder().encode(adjacency) else { return }
        write(data, to: url, key: key)
    }

    // MARK: - Maintenance
    /// Bytes the saved map takes on disk.
    static func savedSize() -> Int {
        guard let directory else { return 0 }
        let files = (try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.fileSizeKey]
        )) ?? []
        return files.reduce(0) { total, file in
            total + ((try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
        }
    }

    static func removeAll() {
        guard let directory else { return }
        try? FileManager.default.removeItem(at: directory)
    }
}

// MARK: - Files
private extension MapDiskCache {
    static var directory: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appending(path: "MapShapes", directoryHint: .isDirectory)
    }

    static func shapesURL(projection: MapProjectionKind, key: String) -> URL? {
        directory?.appending(path: "\(projection.rawValue)-\(key).shapes")
    }

    static func adjacencyURL(key: String) -> URL? {
        directory?.appending(path: "adjacency-\(key).json")
    }

    /// Writes the file and removes any saved under an older key, so outdated maps don't pile up.
    static func write(_ data: Data, to url: URL, key: String) {
        let fileManager = FileManager.default
        guard let directory else { return }
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try? data.write(to: url, options: .atomic)
        let files = (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        for file in files where !file.lastPathComponent.contains(key) {
            try? fileManager.removeItem(at: file)
        }
    }

    /// FNV-1a: stable across launches, unlike `hashValue`.
    static func hexHash(_ text: String) -> String {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in text.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100_0000_01b3
        }
        return String(hash, radix: 16)
    }
}
