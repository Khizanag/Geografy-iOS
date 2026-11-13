@testable import Geografy_Feature_DistanceCalculator
import Testing

@Suite("CompassDirection")
struct CompassDirectionTests {
    @Test(
        "A bearing maps to its nearest compass point",
        arguments: [
            (0.0, CompassDirection.north),
            (22.4, .north),
            (22.6, .northeast),
            (90.0, .east),
            (135.0, .southeast),
            (180.0, .south),
            (225.0, .southwest),
            (270.0, .west),
            (315.0, .northwest),
            (359.0, .north),
            (360.0, .north),
            (-90.0, .west),
            (450.0, .east),
        ]
    )
    func nearestPoint(bearing: Double, direction: CompassDirection) {
        #expect(CompassDirection(bearing: bearing) == direction)
    }
}
