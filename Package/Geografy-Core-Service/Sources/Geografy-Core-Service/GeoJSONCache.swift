import Foundation
import Geografy_Core_Common
import Geografy_Core_DesignSystem

/// The world's country outlines in the chosen projection, colored from the chosen palette, and kept for every
/// map. Outlines are saved on disk once parsed, so a later launch or a switch back to a projection already seen
/// reads them instead of parsing the map again; another palette only colors them again.
@Observable
@MainActor
public final class GeoJSONCache {
    public private(set) var shapes: [CountryShape] = []
    /// The projection `shapes` are in; nil until the first load.
    public private(set) var projection: MapProjectionKind?
    /// The palette `shapes` are colored from.
    public private(set) var palette: MapPalette?
    /// Goes up whenever the outlines change for a reason other than projection or palette, such as a
    /// territorial-dispute choice, so open maps know to load again.
    public private(set) var revision = 0

    private var outlines: [CountryShape] = []
    private var outlinesByProjection: [MapProjectionKind: [CountryShape]] = [:]
    /// Which countries touch doesn't depend on the projection, so it's worked out once.
    private var adjacency: MapAdjacency?
    /// Each palette's color for each country. It depends only on which countries touch, not the projection,
    /// so it's worked out once per palette.
    private var colorIndexes: [MapPalette: [String: Int]] = [:]
    private var loadTask: (projection: MapProjectionKind, task: Task<Parsed, Never>)?

    private struct Parsed: Sendable {
        let shapes: [CountryShape]
        let adjacency: MapAdjacency?
    }

    public init() {}

    /// Whether `shapes` are ready in the projection and palette chosen now.
    public var isLoaded: Bool { projection == MapProjection.current && palette == MapPalette.current }

    /// Parses the world map ahead of time so the Map tab opens without a wait.
    public func preload() async {
        _ = await loadShapes()
    }

    /// The outlines in the projection chosen now, colored from the palette chosen now. A new projection
    /// parses the map again; a new palette only colors it again, which takes a few milliseconds.
    public func loadShapes() async -> [CountryShape] {
        let projection = MapProjection.current
        if self.projection != projection {
            if let cached = outlinesByProjection[projection] {
                outlines = cached
            } else {
                guard let parsed = await parse(in: projection, buildingAdjacency: adjacency == nil) else {
                    return shapes
                }
                outlines = parsed.shapes
                // Only the projection on screen is kept; switching back reads the saved outlines from disk,
                // so a second world's outlines don't sit in memory for a switch that rarely comes.
                outlinesByProjection = [projection: parsed.shapes]
                adjacency = adjacency ?? parsed.adjacency
            }
            self.projection = projection
            palette = nil
        }
        let palette = MapPalette.current
        if self.palette != palette {
            let indexes = await colorIndexes(for: palette)
            let colors = palette.colors
            shapes = outlines.map { $0.recolored(colors[indexes[$0.id] ?? 0]) }
            self.palette = palette
        }
        return shapes
    }

    /// Colors the map off the main thread: it weighs every country against its neighbors, which would
    /// otherwise hold up the first frames at launch.
    private func colorIndexes(for palette: MapPalette) async -> [String: Int] {
        if let cached = colorIndexes[palette] { return cached }
        let codes = Array(Set(outlines.map(\.id))).sorted()
        let adjacency = adjacency ?? MapAdjacency(neighbors: [:])
        let distances = palette.distances
        let revision = revision
        let indexes = await Task.detached(priority: .userInitiated) {
            MapColoringEngine.assign(codes: codes, adjacency: adjacency, distances: distances)
        }.value
        // A map invalidated meanwhile may have different borders, so this coloring isn't kept for it.
        if revision == self.revision {
            colorIndexes[palette] = indexes
        }
        return indexes
    }

    /// Drops every parsed outline, for when what the map contains changes, such as a territorial-dispute choice.
    public func invalidate() {
        outlinesByProjection = [:]
        adjacency = nil
        colorIndexes = [:]
        loadTask = nil
        projection = nil
        palette = nil
        revision += 1
    }

    /// Bytes the map saved between launches takes on disk.
    public var savedMapSize: Int { MapDiskCache.savedSize() }

    /// Deletes the map saved between launches and drops the parsed one, so the next map parses from scratch.
    public func clearSavedMap() {
        MapDiskCache.removeAll()
        invalidate()
    }

    /// Nil when a newer projection was asked for meanwhile, so switching back and forth never keeps stale shapes.
    private func parse(in projection: MapProjectionKind, buildingAdjacency: Bool) async -> Parsed? {
        if let loadTask, loadTask.projection == projection {
            return await loadTask.task.value
        }
        // Utility, so parsing the map never competes with the first screens drawing.
        let task = Task.detached(priority: .utility) { () -> Parsed in
            let key = MapDiskCache.key()
            let shapes = MapDiskCache.loadShapes(projection: projection, key: key) ?? Self.parseMap(
                in: projection,
                savingUnder: key
            )
            guard buildingAdjacency, !shapes.isEmpty else { return Parsed(shapes: shapes, adjacency: nil) }
            if let saved = MapDiskCache.loadAdjacency(key: key) {
                return Parsed(shapes: shapes, adjacency: saved)
            }
            let adjacency = MapAdjacency.build(from: shapes)
            MapDiskCache.saveAdjacency(adjacency, key: key)
            return Parsed(shapes: shapes, adjacency: adjacency)
        }
        loadTask = (projection, task)
        let parsed = await task.value
        guard loadTask?.projection == projection else { return nil }
        loadTask = nil
        return parsed
    }

    /// The outlines from the GeoJSON, saved for the next launch; empty when the file can't be read.
    nonisolated private static func parseMap(
        in projection: MapProjectionKind,
        savingUnder key: String
    ) -> [CountryShape] {
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "geojson"),
              let data = try? Data(contentsOf: url) else { return [] }
        let shapes = GeoJSONParser.parse(data: data, projection: projection)
        if !shapes.isEmpty {
            MapDiskCache.saveShapes(shapes, projection: projection, key: key)
        }
        return shapes
    }
}
