/// One of the eight compass points, for saying which way a route sets off.
enum CompassDirection: CaseIterable {
    case north
    case northeast
    case east
    case southeast
    case south
    case southwest
    case west
    case northwest

    // MARK: - Init
    /// The nearest point to a bearing in degrees clockwise from north; any angle, including negative ones.
    init(bearing: Double) {
        let normalized = (bearing.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        let index = Int((normalized / 45).rounded()) % Self.allCases.count
        self = Self.allCases[index]
    }

    // MARK: - Properties
    var abbreviation: String {
        switch self {
        case .north: "N"
        case .northeast: "NE"
        case .east: "E"
        case .southeast: "SE"
        case .south: "S"
        case .southwest: "SW"
        case .west: "W"
        case .northwest: "NW"
        }
    }

    var name: String {
        switch self {
        case .north: "North"
        case .northeast: "Northeast"
        case .east: "East"
        case .southeast: "Southeast"
        case .south: "South"
        case .southwest: "Southwest"
        case .west: "West"
        case .northwest: "Northwest"
        }
    }
}
