import CoreGraphics
import SwiftUI

enum GeoJSONParser {
    private static var territoryMergeMap: [String: String] {
        TerritorialDispute.all.reduce(into: [:]) { map, dispute in
            guard let geoJSONName = dispute.geoJSONName else { return }
            let stored = UserDefaults.standard.string(forKey: dispute.userDefaultsKey)
            let selectedKey: String
            if let stored, dispute.options.contains(where: { $0.key == stored }) {
                selectedKey = stored
            } else {
                selectedKey = dispute.defaultOptionKey
            }
            if let option = dispute.options.first(where: { $0.key == selectedKey }),
               let mergeCode = option.mergesInto {
                map[geoJSONName] = mergeCode
            }
        }
    }

    private static let filteredTerritories: Set<String> = [
        "Bir Tawil", "Cyprus U.N. Buffer Zone", "Siachen Glacier",
        "Bajo Nuevo Bank", "Scarborough Reef", "Serranilla Bank", "Spratly Is.",
        "Southern Patagonian Ice Field", "Brazilian I.",
        "Akrotiri", "Dhekelia", "Baikonur", "USNB Guantanamo Bay",
        "Clipperton I.", "Coral Sea Is.", "Indian Ocean Ter.", "Ashmore and Cartier Is.",
    ]

    // Manual label position overrides (longitude, latitude) for countries where automatic
    // centroid calculation places the label incorrectly (overseas territories, island nations
    // crossing the antimeridian, or extremely elongated shapes).
    private static let labelOverrides: [String: (longitude: Double, latitude: Double)] = [
        "FR": (2.2, 46.2),      // France — skip overseas territories (French Guiana, Réunion, etc.)
        "PT": (-8.0, 39.5),     // Portugal — skip Azores & Madeira
        "IL": (34.9, 31.4),     // Israel — center on mainland, avoid West Bank area
        "KI": (173.0, 1.5),     // Kiribati — Gilbert Islands (antimeridian crossing fix)
        "NZ": (172.6, -41.5),   // New Zealand — South Island center
        "NO": (15.0, 65.0),     // Norway — mainland, skip Svalbard
        "US": (-98.4, 39.5),    // USA — continental center
        "RU": (90.0, 61.5),     // Russia — centered on Siberian mainland
        "CL": (-71.0, -35.0),   // Chile — mid-country (extreme north–south length)
        "ES": (-3.7, 40.2),     // Spain — mainland, skip Canary Islands
        "GL": (-42.0, 72.0),    // Greenland — central
        "ID": (117.0, -2.0),    // Indonesia — central (Borneo region)
        "EC": (-78.0, -1.8),    // Ecuador — mainland, skip Galápagos
        "MX": (-102.5, 23.6),   // Mexico — mainland center
        "PH": (122.0, 12.5),    // Philippines — central Visayas
        "JP": (138.0, 36.5),    // Japan — Honshu
        "FJ": (178.0, -17.8),   // Fiji — main islands
        "FM": (158.0, 7.0),     // Micronesia — Chuuk/Pohnpei area
    ]

    static func parse(data: Data) -> [CountryShape] {
        guard let collection = try? JSONDecoder().decode(GeoJSONFeatureCollection.self, from: data) else {
            return []
        }

        var shapes = collection.features.enumerated().compactMap { index, feature in
            parseFeature(feature, at: index)
        }

        shapes = consolidateMergedTerritories(shapes)

        MapColorPalette.assignColors(to: &shapes)

        return shapes
    }
}

// MARK: - Parsing

private extension GeoJSONParser {
    static func parseFeature(_ feature: GeoJSONFeature, at index: Int) -> CountryShape? {
        let rawCode = feature.id ?? extractISOCode(from: feature)
        let name = extractProperty(from: feature, keys: ["name", "NAME", "ADMIN"])
        let continent = extractProperty(from: feature, keys: ["CONTINENT"]) ?? ""

        guard let rawCode, let name, rawCode != "-99" else {
            return nil
        }

        // Filter Antarctica
        guard rawCode != "ATA", name != "Antarctica" else { return nil }

        // Filter non-country territories
        guard !filteredTerritories.contains(name) else { return nil }

        let code = resolveCountryCode(rawCode: rawCode, name: name)

        let ringArrays = extractRings(from: feature.geometry)
        guard !ringArrays.isEmpty else { return nil }

        var allPoints: [CGPoint] = []
        var paths: [CGPath] = []
        var largestPolygonPoints: [CGPoint] = []
        var largestPolygonArea: CGFloat = 0

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

            // Track the largest polygon for label placement.
            // Using only the largest polygon prevents islands and overseas territories
            // from pulling the centroid off the mainland.
            let polygonBBox = calculateBoundingBox(from: projectedPoints)
            let area = polygonBBox.width * polygonBBox.height
            if area > largestPolygonArea {
                largestPolygonArea = area
                largestPolygonPoints = projectedPoints
            }
        }

        guard !paths.isEmpty else { return nil }

        let centroidPoints = largestPolygonPoints.isEmpty ? allPoints : largestPolygonPoints
        var centroid = calculateCentroid(from: centroidPoints)

        // Apply manual override for countries where even the largest-polygon centroid is wrong
        // (e.g. Kiribati crossing the antimeridian, Israel overlapping Palestine).
        if let override = labelOverrides[code] {
            centroid = MapProjection.project(longitude: override.longitude, latitude: override.latitude)
        }

        let boundingBox = calculateBoundingBox(from: allPoints)
        let color = DesignSystem.Color.mapColors[index % DesignSystem.Color.mapColors.count]

        return CountryShape(
            id: code,
            name: name,
            continent: continent,
            polygons: paths,
            centroid: centroid,
            boundingBox: boundingBox,
            color: color
        )
    }

    static func extractProperty(from feature: GeoJSONFeature, keys: [String]) -> String? {
        for key in keys {
            if let value = feature.properties[key]?.stringValue, value != "-99" {
                return value
            }
        }
        return nil
    }

    // Extracts a clean ISO country code, preferring ISO_A2_EH over ISO_A2 for 2-letter codes.
    // ISO_A2 can contain non-standard political encodings like "CN-TW" for Taiwan;
    // ISO_A2_EH always contains the standard alphabetic-only 2-letter code.
    static func extractISOCode(from feature: GeoJSONFeature) -> String? {
        let twoLetterKeys = ["ISO_A2_EH", "ISO_A2", "iso_a2"]
        for key in twoLetterKeys {
            if let value = feature.properties[key]?.stringValue,
               value != "-99",
               value.count == 2,
               value.allSatisfy(\.isLetter) {
                return value
            }
        }
        let threeLetterKeys = ["ISO_A3", "iso_a3", "ADM0_A3"]
        for key in threeLetterKeys {
            if let value = feature.properties[key]?.stringValue, value != "-99" {
                return value
            }
        }
        return nil
    }

    static func resolveCountryCode(rawCode: String, name: String) -> String {
        if let mergeCode = territoryMergeMap[name] {
            return mergeCode
        }
        if rawCode.count == 3 {
            return ISOCountryCodes.alpha2(from: rawCode) ?? rawCode
        }
        return rawCode
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

// MARK: - Territory Consolidation

private extension GeoJSONParser {
    // When a disputed territory (e.g. W. Sahara) merges into another country (e.g. Morocco),
    // both shapes end up with the same country code. This function merges their polygon lists
    // into a single CountryShape, keeping the larger shape's name and centroid as primary.
    // This prevents merged territories from rendering their own label on the map.
    static func consolidateMergedTerritories(_ shapes: [CountryShape]) -> [CountryShape] {
        var result: [CountryShape] = []
        var indexById: [String: Int] = [:]

        for shape in shapes {
            if let existingIndex = indexById[shape.id] {
                let existing = result[existingIndex]
                let existingArea = existing.boundingBox.width * existing.boundingBox.height
                let shapeArea = shape.boundingBox.width * shape.boundingBox.height

                if shapeArea > existingArea {
                    // Incoming shape is the larger country; absorb existing as merged territory
                    result[existingIndex] = CountryShape(
                        id: shape.id,
                        name: shape.name,
                        continent: shape.continent,
                        polygons: shape.polygons + existing.polygons,
                        centroid: shape.centroid,
                        boundingBox: shape.boundingBox.union(existing.boundingBox),
                        color: shape.color
                    )
                } else {
                    // Existing shape is the larger country; absorb incoming as merged territory
                    result[existingIndex] = CountryShape(
                        id: existing.id,
                        name: existing.name,
                        continent: existing.continent,
                        polygons: existing.polygons + shape.polygons,
                        centroid: existing.centroid,
                        boundingBox: existing.boundingBox.union(shape.boundingBox),
                        color: existing.color
                    )
                }
            } else {
                indexById[shape.id] = result.count
                result.append(shape)
            }
        }

        return result
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
