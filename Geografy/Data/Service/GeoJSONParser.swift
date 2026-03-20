import CoreGraphics
import SwiftUI

enum GeoJSONParser {
    static func parse(data: Data) -> [CountryShape] {
        guard let collection = try? JSONDecoder().decode(GeoJSONFeatureCollection.self, from: data) else {
            return []
        }

        var shapes = collection.features.enumerated().compactMap { index, feature in
            parseFeature(feature, at: index)
        }

        MapColorPalette.assignColors(to: &shapes)

        return shapes
    }
}

// MARK: - Parsing

private extension GeoJSONParser {
    static func parseFeature(_ feature: GeoJSONFeature, at index: Int) -> CountryShape? {
        let rawCode = feature.id
            ?? extractProperty(from: feature, keys: ["ISO_A2", "iso_a2", "ISO_A3", "iso_a3"])
        let name = extractProperty(from: feature, keys: ["name", "NAME", "ADMIN"])

        guard let rawCode, let name, rawCode != "-99" else {
            return nil
        }

        // Filter Antarctica
        guard rawCode != "ATA", name != "Antarctica" else { return nil }

        // Convert 3-letter to 2-letter ISO code if needed
        let code: String
        if rawCode.count == 3 {
            code = ISOCountryCodes.alpha2(from: rawCode) ?? rawCode
        } else {
            code = rawCode
        }

        let ringArrays = extractRings(from: feature.geometry)
        guard !ringArrays.isEmpty else { return nil }

        var allPoints: [CGPoint] = []
        var paths: [CGPath] = []

        for rings in ringArrays {
            guard let outerRing = rings.first else { continue }

            let projectedPoints = outerRing.compactMap { coord -> CGPoint? in
                guard coord.count >= 2 else { return nil }
                return MapProjection.project(longitude: coord[0], latitude: coord[1])
            }

            guard projectedPoints.count >= 3 else { continue }

            let path = CGMutablePath()
            path.move(to: projectedPoints[0])
            for point in projectedPoints.dropFirst() {
                path.addLine(to: point)
            }
            path.closeSubpath()

            paths.append(path)
            allPoints.append(contentsOf: projectedPoints)
        }

        guard !paths.isEmpty else { return nil }

        let centroid = calculateCentroid(from: allPoints)
        let boundingBox = calculateBoundingBox(from: allPoints)
        let color = DesignSystem.Color.mapColors[index % DesignSystem.Color.mapColors.count]

        return CountryShape(
            id: code,
            name: name,
            polygons: paths,
            centroid: centroid,
            boundingBox: boundingBox,
            color: color
        )
    }

    static func extractProperty(from feature: GeoJSONFeature, keys: [String]) -> String? {
        for key in keys {
            if let value = feature.properties[key]?.stringValue {
                return value
            }
        }
        return nil
    }

    static func extractRings(from geometry: GeoJSONGeometry) -> [[[[Double]]]] {
        switch geometry.coordinates {
        case .polygon(let rings):
            [rings]
        case .multiPolygon(let polygons):
            polygons
        }
    }
}

// MARK: - Geometry Calculations

private extension GeoJSONParser {
    static func calculateCentroid(from points: [CGPoint]) -> CGPoint {
        guard !points.isEmpty else { return .zero }
        let sumX = points.reduce(0.0) { $0 + $1.x }
        let sumY = points.reduce(0.0) { $0 + $1.y }
        let count = CGFloat(points.count)
        return CGPoint(x: sumX / count, y: sumY / count)
    }

    static func calculateBoundingBox(from points: [CGPoint]) -> CGRect {
        guard let first = points.first else { return .zero }
        var minX = first.x
        var minY = first.y
        var maxX = first.x
        var maxY = first.y

        for point in points.dropFirst() {
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
