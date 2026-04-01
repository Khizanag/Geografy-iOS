import Foundation

public struct MapTarget: Identifiable {
    public let id = UUID()
    public let continentFilter: String?

    public init(continentFilter: String?) {
        self.continentFilter = continentFilter
    }
}
