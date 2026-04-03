import Foundation
import Geografy_Core_Common

@Observable
@MainActor
public final class GeoJSONCache {
    public private(set) var shapes: [CountryShape] = []
    public private(set) var isLoaded = false

    private var loadTask: Task<[CountryShape], Never>?

    public init() {}

    public func loadShapes() async -> [CountryShape] {
        if isLoaded { return shapes }

        if let existingTask = loadTask {
            return await existingTask.value
        }

        let task = Task.detached(priority: .userInitiated) { () -> [CountryShape] in
            guard let url = Bundle.main.url(forResource: "countries", withExtension: "geojson"),
                  let data = try? Data(contentsOf: url) else { return [] }
            return GeoJSONParser.parse(data: data)
        }

        loadTask = task
        let result = await task.value

        shapes = result
        isLoaded = true
        loadTask = nil

        return result
    }
}
