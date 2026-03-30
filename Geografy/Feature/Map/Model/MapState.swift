import SwiftUI

@Observable
final class MapState {
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero
    var lastScale: CGFloat = 1.0
    var lastOffset: CGSize = .zero
    var minScale: CGFloat = 0.15
    static let maxScale: CGFloat = 100.0
    var selectedCountryCode: String?
    var showLabels = false
    var countryShapes: [CountryShape] = []
    var contentBounds: CGRect = .zero

    var selectedShape: CountryShape? {
        countryShapes.first { $0.id == selectedCountryCode }
    }
}

// MARK: - Actions
extension MapState {
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
