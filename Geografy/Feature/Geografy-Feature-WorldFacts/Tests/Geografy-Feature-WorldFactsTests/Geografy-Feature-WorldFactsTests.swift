import Geografy_Core_Navigation
@testable import Geografy_Feature_WorldFacts
import Testing

@Suite("World Facts")
struct WorldFactsTests {
    @Test("Every topic has a title")
    func topicTitles() {
        for topic in WorldFactsTopic.allCases {
            #expect(!topic.title.isEmpty)
        }
    }

    @Test("Oceans and seas are both listed")
    func oceansAndSeas() {
        let service = OceanService()

        #expect(!service.oceansList.isEmpty)
        #expect(!service.seasList.isEmpty)
    }

    @Test("Every geography feature type has entries", arguments: GeographyFeatureType.allCases)
    func featureTypes(type: GeographyFeatureType) {
        #expect(!GeographyFeaturesService().features(for: type).isEmpty)
    }

    @Test("All landmarks are listed when no category is chosen")
    func allLandmarks() {
        #expect(!LandmarkGalleryService().landmarks(in: nil).isEmpty)
    }
}
