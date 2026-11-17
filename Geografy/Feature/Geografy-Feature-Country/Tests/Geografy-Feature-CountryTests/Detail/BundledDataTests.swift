import Geografy_Core_Common
@testable import Geografy_Feature_Country
import Testing

@Suite("Bundled country data")
struct BundledDataTests {
    @Test("Every country data file loads all of its entries")
    func everyFileLoads() {
        #expect(FlagSymbolismData.data.count == 98)
        #expect(CountryFunFacts.data.count == 160)
        #expect(LanguageProfiles.all.count == 38)
        #expect(UNESCOData.data.count == 65)
        #expect(CountryCulture.data.count == 51)
        #expect(ReligionData.data.count == 194)
        #expect(EthnicityData.data.count == 194)
    }

    @Test("Entries keep their fields, including optional ones")
    func fieldsSurvive() throws {
        let france = try #require(FlagSymbolismData.data["FR"])
        #expect(!france.colors.isEmpty)
        #expect(france.historicalNote != nil)
        #expect(CountryCulture.data["IN"]?.greeting == "Namaste")
        #expect(LanguageProfiles.official(in: "CN").first?.id == "zh")
    }
}
