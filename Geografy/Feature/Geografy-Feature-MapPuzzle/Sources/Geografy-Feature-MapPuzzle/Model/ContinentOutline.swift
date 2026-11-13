import CoreGraphics
import Geografy_Core_Common

/// A continent's countries as one path in map space, and the window that frames its mainland.
struct ContinentOutline: @unchecked Sendable {
    let continent: Country.Continent
    let path: CGPath
    let viewport: CGRect
}

// MARK: - Building
extension ContinentOutline {
    /// Joins the polygons of every shape on `continent`; `nil` when none match or the continent has no framing.
    init?(continent: Country.Continent, shapes: [CountryShape]) {
        guard let viewport = Self.viewport(for: continent) else { return nil }
        let path = CGMutablePath()
        for shape in shapes where shape.continent == continent.displayName {
            for polygon in shape.polygons {
                path.addPath(polygon)
            }
        }
        guard !path.isEmpty else { return nil }
        self.init(continent: continent, path: path, viewport: viewport)
    }

    static func outlines(
        for continents: [Country.Continent],
        shapes: [CountryShape]
    ) -> [Country.Continent: ContinentOutline] {
        continents.reduce(into: [:]) { outlines, continent in
            outlines[continent] = ContinentOutline(continent: continent, shapes: shapes)
        }
    }

    /// The projected window around the mainland. It crops outliers such as Russia east of the Urals,
    /// overseas territories, and islands across the antimeridian, which would shrink the silhouette.
    static func viewport(for continent: Country.Continent) -> CGRect? {
        guard let bounds = geographicBounds(for: continent) else { return nil }
        let topLeft = MapProjection.project(
            longitude: bounds.longitude.lowerBound,
            latitude: bounds.latitude.upperBound
        )
        let bottomRight = MapProjection.project(
            longitude: bounds.longitude.upperBound,
            latitude: bounds.latitude.lowerBound
        )
        return CGRect(
            x: topLeft.x,
            y: topLeft.y,
            width: bottomRight.x - topLeft.x,
            height: bottomRight.y - topLeft.y
        )
    }
}

// MARK: - Fitting
extension ContinentOutline {
    /// Maps the viewport into `size`, centered, keeping its aspect ratio.
    func fittingTransform(in size: CGSize) -> CGAffineTransform {
        guard viewport.width > 0, viewport.height > 0, size.width > 0, size.height > 0 else { return .identity }
        let scale = min(size.width / viewport.width, size.height / viewport.height)
        let offsetX = (size.width - viewport.width * scale) / 2 - viewport.minX * scale
        let offsetY = (size.height - viewport.height * scale) / 2 - viewport.minY * scale
        return CGAffineTransform(a: scale, b: 0, c: 0, d: scale, tx: offsetX, ty: offsetY)
    }
}

// MARK: - Helpers
private extension ContinentOutline {
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
