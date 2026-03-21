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
