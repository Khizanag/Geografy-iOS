@testable import Geografy_Feature_Discover
import Testing

@Suite("Landmark data")
struct LandmarkDataTests {
    @Test("Every bundled landmark loads, with its category")
    func landmarksLoad() {
        let service = LandmarkGalleryService()
        #expect(service.landmarks.count == 42)
        #expect(service.landmarks.first { $0.id == "eiffel-tower" }?.category == .monument)
    }
}
