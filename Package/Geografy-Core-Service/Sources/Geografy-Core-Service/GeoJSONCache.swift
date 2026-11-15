import Foundation
import Geografy_Core_Common
import Geografy_Core_DesignSystem

/// The world's country outlines, parsed once per projection, colored from the chosen palette,
/// and kept for every map.
@Observable
@MainActor
public final class GeoJSONCache {
    public private(set) var shapes: [CountryShape] = []
    /// The projection `shapes` are in; nil until the first load.
    public private(set) var projection: MapProjectionKind?
    /// The palette `shapes` are colored from.
    public private(set) var palette: MapPalette?

    private var outlines: [CountryShape] = []
    private var adjacency = MapAdjacency(neighbors: [:])
    private var loadTask: (projection: MapProjectionKind, task: Task<Parsed, Never>)?

    private struct Parsed: Sendable {
        let shapes: [CountryShape]
        let adjacency: MapAdjacency
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
            guard let parsed = await parse(in: projection) else { return shapes }
            outlines = parsed.shapes
            adjacency = parsed.adjacency
            self.projection = projection
            palette = nil
        }
        let palette = MapPalette.current
        if self.palette != palette {
            shapes = MapColoringEngine.colored(outlines, adjacency: adjacency, palette: palette)
            self.palette = palette
        }
        return shapes
    }

    /// Nil when a newer projection was asked for meanwhile, so switching back and forth never keeps stale shapes.
    private func parse(in projection: MapProjectionKind) async -> Parsed? {
        if let loadTask, loadTask.projection == projection {
            return await loadTask.task.value
        }
        // Utility, so parsing the map never competes with the first screens drawing.
        let task = Task.detached(priority: .utility) { () -> Parsed in
            guard let url = Bundle.main.url(forResource: "countries", withExtension: "geojson"),
                  let data = try? Data(contentsOf: url) else {
                return Parsed(shapes: [], adjacency: MapAdjacency(neighbors: [:]))
            }
            let shapes = GeoJSONParser.parse(data: data, projection: projection)
            return Parsed(shapes: shapes, adjacency: MapAdjacency.build(from: shapes))
        }
        loadTask = (projection, task)
        let parsed = await task.value
        guard loadTask?.projection == projection else { return nil }
        loadTask = nil
        return parsed
    }
}
