import Foundation
import Geografy_Core_Common

/// The language the app's text is in. A change swaps the text on screen in place,
/// through the `locale` the app root hands every screen, and iOS opens the app in it
/// from the next launch on.
@MainActor
@Observable
public final class LanguageService {
    // MARK: - Properties
    public var language: AppLanguage {
        didSet {
            guard language != oldValue else { return }
            locale = language.locale()
            language.keep(in: defaults)
        }
    }

    /// `language` with the device's region, for looking text up and formatting it.
    public private(set) var locale: Locale

    /// Whether there's a second language to switch to.
    public var isChoosable: Bool { languages.count > 1 }

    public let languages: [AppLanguage]

    /// Whether Geografy's page in iOS Settings has a language option. iOS shows one only once
    /// the device lists more than one language in Settings › General › Language & Region.
    public var isChoosableInSystemSettings: Bool {
        isChoosable && deviceLanguages().count > 1
    }

    private let defaults: UserDefaults
    private let deviceLanguages: () -> [String]

    // MARK: - Init
    /// - Parameter defaults: Where the choice is kept; tests pass their own, so a run never changes the app's language.
    public init(
        languages: [AppLanguage] = AppLanguage.all,
        preferences: [String] = Locale.preferredLanguages,
        defaults: UserDefaults = .standard,
        deviceLanguages: @escaping () -> [String] = LanguageService.deviceLanguages
    ) {
        let language = AppLanguage.resolved(from: preferences, among: languages)
        self.languages = languages
        self.defaults = defaults
        self.deviceLanguages = deviceLanguages
        self.language = language
        locale = language.locale()
    }
}

// MARK: - Device Languages
public extension LanguageService {
    /// The device's languages from Settings › General › Language & Region. Unlike
    /// `Locale.preferredLanguages`, this ignores the language chosen for the app alone.
    nonisolated static func deviceLanguages() -> [String] {
        // The any-application lookup skips the app's own domain, where a language chosen for Geografy is kept.
        CFPreferencesCopyAppValue("AppleLanguages" as CFString, kCFPreferencesAnyApplication) as? [String] ?? []
    }
}
