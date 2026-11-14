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

    private let defaults: UserDefaults

    // MARK: - Init
    /// - Parameter defaults: Where the choice is kept; tests pass their own, so a run never changes the app's language.
    public init(
        languages: [AppLanguage] = AppLanguage.all,
        preferences: [String] = Locale.preferredLanguages,
        defaults: UserDefaults = .standard
    ) {
        let language = AppLanguage.resolved(from: preferences, among: languages)
        self.languages = languages
        self.defaults = defaults
        self.language = language
        locale = language.locale()
    }
}
