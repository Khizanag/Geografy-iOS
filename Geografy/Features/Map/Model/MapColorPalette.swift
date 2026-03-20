import SwiftUI

enum MapColorPalette {
    static func color(for countryCode: String, at index: Int) -> Color {
        let colors = GeoColors.mapColors

        var hash = 0
        for char in countryCode.unicodeScalars {
            hash = hash &* 31 &+ Int(char.value)
        }

        let colorIndex = abs(hash) % colors.count
        return colors[colorIndex]
    }
}
