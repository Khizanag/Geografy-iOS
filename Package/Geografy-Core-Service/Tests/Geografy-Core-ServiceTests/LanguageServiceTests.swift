import Foundation
import Geografy_Core_Common
@testable import Geografy_Core_Service
import Testing

@Suite("LanguageService")
@MainActor
struct LanguageServiceTests {
    private let englishAndGeorgian = ["en", "ka"].map(AppLanguage.init(code:))

    @Test("Until someone chooses, the device's languages decide")
    func deviceDecides() {
        #expect(AppLanguage.resolved(from: ["ka-GE", "en-US"], among: englishAndGeorgian).code == "ka")
        #expect(AppLanguage.resolved(from: ["ru-GE", "ka-GE"], among: englishAndGeorgian).code == "ka")
        #expect(AppLanguage.resolved(from: ["en-GB", "ka-GE"], among: englishAndGeorgian).code == "en")
        #expect(AppLanguage.resolved(from: ["de-DE"], among: englishAndGeorgian).code == "en")
    }

    @Test("Each language is named in itself")
    func endonyms() {
        #expect(AppLanguage(code: "en").endonym == "English")
        #expect(AppLanguage(code: "ka").endonym == "ქართული")
    }

    @Test("A language keeps the device's region")
    func keepsTheRegion() {
        let georgian = AppLanguage(code: "ka").locale(basedOn: Locale(identifier: "en_GE"))

        #expect(georgian.language.languageCode == Locale.LanguageCode("ka"))
        #expect(georgian.region == Locale.Region("GE"))
    }

    @Test("Choosing a language switches the locale and keeps the choice for the next launch")
    func choosingKeepsTheChoice() throws {
        let suite = "LanguageServiceTests.choosingKeepsTheChoice"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let service = LanguageService(languages: englishAndGeorgian, preferences: ["en-US"], defaults: defaults)

        #expect(service.language.code == "en")
        #expect(service.isChoosable)

        service.language = AppLanguage(code: "ka")

        #expect(service.locale.language.languageCode == Locale.LanguageCode("ka"))
        #expect(defaults.stringArray(forKey: AppLanguage.preferenceKey) == ["ka"])
    }

    @Test("iOS Settings offers a language only once the device lists more than one")
    func systemSettingsNeedsTwoDeviceLanguages() {
        let oneLanguage = LanguageService(languages: englishAndGeorgian, deviceLanguages: { ["en-US"] })
        let twoLanguages = LanguageService(languages: englishAndGeorgian, deviceLanguages: { ["en-US", "ka-GE"] })

        #expect(!oneLanguage.isChoosableInSystemSettings)
        #expect(twoLanguages.isChoosableInSystemSettings)
    }

    @Test("An app with one language has nothing to choose in iOS Settings")
    func systemSettingsNeedsTwoAppLanguages() {
        let service = LanguageService(languages: [AppLanguage(code: "en")], deviceLanguages: { ["en-US", "ka-GE"] })

        #expect(!service.isChoosableInSystemSettings)
    }

    @Test("Text built in code follows the chosen language")
    func codeBuiltTextFollowsTheLocale() {
        let georgian = Locale(identifier: "ka")
        #expect(LocalizedStringResource("Settings", locale: georgian).locale == georgian)
    }
}
