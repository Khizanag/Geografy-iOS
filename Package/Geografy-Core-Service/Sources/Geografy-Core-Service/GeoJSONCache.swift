import Foundation
import Geografy_Core_Common

/// The world's country outlines, parsed once per projection and kept for every map.
@Observable
@MainActor
public final class GeoJSONCache {
    public private(set) var shapes: [CountryShape] = []
    /// The projection `shapes` are in; nil until the first load.
    public private(set) var projection: MapProjectionKind?

    private var loadTask: (projection: MapProjectionKind, task: Task<[CountryShape], Never>)?

    public init() {}

    /// Whether `shapes` are ready in the projection chosen now.
    public var isLoaded: Bool { projection == MapProjection.current }

    /// Parses the world map ahead of time so the Map tab opens without a wait.
    public func preload() async {
        _ = await loadShapes()
    }

    /// The outlines in the projection chosen now, parsing them again after the projection changes.
    public func loadShapes() async -> [CountryShape] {
        let projection = MapProjection.current
        if self.projection == projection { return shapes }

        if let loadTask, loadTask.projection == projection {
            return await loadTask.task.value
        }

        // Utility, so parsing the map never competes with the first screens drawing.
        let task = Task.detached(priority: .utility) { () -> [CountryShape] in
            guard let url = Bundle.main.url(forResource: "countries", withExtension: "geojson"),
                  let data = try? Data(contentsOf: url) else { return [] }
            return GeoJSONParser.parse(data: data, projection: projection)
        }

        loadTask = (projection, task)
        let result = await task.value

        // Only the projection asked for last is kept, so switching back and forth never leaves stale shapes.
        if loadTask?.projection == projection {
            shapes = result
            self.projection = projection
            loadTask = nil
        }
        return result
    }
}
