@testable import Geografy_Feature_Play
import Testing

@Suite("Country nicknames")
struct CountryNicknamesTests {
    @Test("Every bundled nickname loads")
    func nicknamesLoad() {
        #expect(CountryNicknames.data.count == 48)
        #expect(CountryNicknames.data["AR"]?.first?.nickname == "Land of Silver")
    }
}
