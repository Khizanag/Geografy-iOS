import SwiftUI

@MainActor
@Observable
public final class MapState {
    public var scale: CGFloat = 1.0
    public var offset: CGSize = .zero
    public var lastScale: CGFloat = 1.0
    public var lastOffset: CGSize = .zero
    public var minScale: CGFloat = 0.15
    public static let maxScale: CGFloat = 100.0
    public var selectedCountryCode: String?
    public var showLabels = false
    public var countryShapes: [CountryShape] = []
    public var contentBounds: CGRect = .zero

    public var selectedShape: CountryShape? {
        countryShapes.first { $0.id == selectedCountryCode }
    }

    public init() {}
}

// MARK: - Actions
public extension MapState {
    func reset() {
        scale = 1.0
        offset = .zero
        lastScale = 1.0
        lastOffset = .zero
        selectedCountryCode = nil
    }

    func clampOffset(in size: CGSize) {
        let maxOffsetX = max(0, (MapProjection.mapWidth * scale - size.width) / 2)
        let maxOffsetY = max(0, (MapProjection.mapHeight * scale - size.height) / 2)

        offset.width = min(max(offset.width, -maxOffsetX), maxOffsetX)
        offset.height = min(max(offset.height, -maxOffsetY), maxOffsetY)
    }
}
