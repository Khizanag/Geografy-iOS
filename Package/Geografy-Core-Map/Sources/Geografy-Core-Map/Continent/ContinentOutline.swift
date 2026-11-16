import CoreGraphics
import Geografy_Core_Common

/// A continent's countries as one path in map space, and the window that frames its mainland.
public struct ContinentOutline: @unchecked Sendable {
    public let continent: Country.Continent
    public let path: CGPath
    public let viewport: CGRect
    /// Each country's own path, keyed by country code, so one can be highlighted on the continent.
    public var countryPaths: [String: CGPath] = [:]
}

// MARK: - Building
extension ContinentOutline {
    /// How much of the map an outline keeps.
    public enum Detail: Sendable {
        /// The coarsest outline and no per-country paths, for thumbnails a few dozen points tall.
        case silhouette
        /// An outline fine enough for a full-width map, plus every country's full-detail path to highlight.
        case puzzle
    }

    /// Joins the polygons of every shape on `continent`; `nil` when none match or the continent has no framing.
    public init?(continent: Country.Continent, shapes: [CountryShape], detail: Detail = .puzzle) {
        guard let viewport = Self.viewport(for: continent) else { return nil }
        let path = CGMutablePath()
        var countryPaths: [String: CGPath] = [:]
        for shape in shapes where shape.continent == continent.displayName {
            switch detail {
            case .silhouette:
                Self.add(shape.detailPaths.first, orPolygonsOf: shape, to: path)
            case .puzzle:
                Self.add(shape.detailPath(forScale: Self.puzzleScale), orPolygonsOf: shape, to: path)
                let countryPath = CGMutablePath()
                shape.polygons.forEach { countryPath.addPath($0) }
                countryPaths[shape.id] = countryPath
            }
        }
        guard !path.isEmpty else { return nil }
        self.init(continent: continent, path: path, viewport: viewport, countryPaths: countryPaths)
    }

    public static func outlines(
        for continents: [Country.Continent],
        shapes: [CountryShape],
        detail: Detail = .silhouette
    ) -> [Country.Continent: ContinentOutline] {
        continents.reduce(into: [:]) { outlines, continent in
            outlines[continent] = ContinentOutline(continent: continent, shapes: shapes, detail: detail)
        }
    }

    /// Builds the region thumbnails off the main actor.
    @concurrent
    public static func silhouettes(
        for continents: [Country.Continent],
        shapes: [CountryShape]
    ) async -> [Country.Continent: ContinentOutline] {
        outlines(for: continents, shapes: shapes, detail: .silhouette)
    }

    /// Builds one continent's puzzle map off the main actor.
    @concurrent
    public static func puzzleOutline(
        for continent: Country.Continent,
        shapes: [CountryShape]
    ) async -> ContinentOutline? {
        ContinentOutline(continent: continent, shapes: shapes, detail: .puzzle)
    }

    /// The projected window around the mainland. It crops outliers such as Russia east of the Urals,
    /// overseas territories, and islands across the antimeridian, which would shrink the silhouette.
    public static func viewport(for continent: Country.Continent) -> CGRect? {
        guard let bounds = geographicBounds(for: continent) else { return nil }
        return MapProjection.boundingRect(
            minLongitude: bounds.longitude.lowerBound,
            maxLongitude: bounds.longitude.upperBound,
            minLatitude: bounds.latitude.lowerBound,
            maxLatitude: bounds.latitude.upperBound
        )
    }
}

// MARK: - Fitting
extension ContinentOutline {
    /// Maps the viewport into `size`, centered, keeping its aspect ratio.
    public func fittingTransform(in size: CGSize) -> CGAffineTransform {
        guard viewport.width > 0, viewport.height > 0, size.width > 0, size.height > 0 else { return .identity }
        let scale = min(size.width / viewport.width, size.height / viewport.height)
        let offsetX = (size.width - viewport.width * scale) / 2 - viewport.minX * scale
        let offsetY = (size.height - viewport.height * scale) / 2 - viewport.minY * scale
        return CGAffineTransform(a: scale, b: 0, c: 0, d: scale, tx: offsetX, ty: offsetY)
    }
}

// MARK: - Helpers
private extension ContinentOutline {
    /// Above the largest scale the puzzle map reaches: its height scales with Dynamic Type, and even
    /// the largest sizes keep a whole continent under 2 points per map unit.
    static let puzzleScale: CGFloat = 2

    static func add(_ detailPath: CGPath?, orPolygonsOf shape: CountryShape, to path: CGMutablePath) {
        if let detailPath {
            path.addPath(detailPath)
        } else {
            shape.polygons.forEach { path.addPath($0) }
        }
    }

    struct GeographicBounds {
        let longitude: ClosedRange<Double>
        let latitude: ClosedRange<Double>
    }

    static func geographicBounds(for continent: Country.Continent) -> GeographicBounds? {
        switch continent {
        case .africa: GeographicBounds(longitude: -20 ... 55, latitude: -35 ... 38)
        case .asia: GeographicBounds(longitude: 26 ... 150, latitude: -11 ... 60)
        case .europe: GeographicBounds(longitude: -25 ... 42, latitude: 34 ... 71)
        case .northAmerica: GeographicBounds(longitude: -170 ... -12, latitude: 7 ... 76)
        case .southAmerica: GeographicBounds(longitude: -82 ... -34, latitude: -56 ... 13)
        case .oceania: GeographicBounds(longitude: 112 ... 180, latitude: -48 ... 2)
        case .antarctica: nil
        }
    }
}
