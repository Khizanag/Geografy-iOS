import Foundation

/// A language the app's own text comes in: one of the localizations it ships.
/// The device's languages pick it until someone chooses one, in the app or in
/// iOS Settings; both keep the choice as the app's `AppleLanguages`.
public struct AppLanguage: Hashable, Identifiable, Sendable {
    // MARK: - Properties
    /// The localization's code: `en`, `ka`.
    public let code: String

    public var id: String { code }

    /// The language's own name for itself — "English", "ქართული" — so anyone
    /// can find theirs, whatever the app is showing.
    public var endonym: String {
        let locale = Locale(identifier: code)
        return locale.localizedString(forLanguageCode: code)?.capitalized(with: locale) ?? code
    }

    /// The flag of the country the language comes from — 🇬🇪 for Georgian, 🇬🇧 for English —
    /// to find a language at a glance. Empty when there's no such country.
    public var flagEmoji: String {
        guard let region = flagRegion, region.count == 2 else { return "" }
        let indicators = region.unicodeScalars.compactMap { Unicode.Scalar(0x1F1E6 - 0x41 + $0.value) }
        return String(String.UnicodeScalarView(indicators))
    }

    /// English is named after England, not the country with the most speakers that iOS would pick.
    /// Every other language takes the country iOS considers its home.
    private var flagRegion: String? {
        if code == "en" { return "GB" }
        return Locale.Language(identifier: Locale.Language(identifier: code).maximalIdentifier).region?.identifier
    }

    // MARK: - Init
    public init(code: String) {
        self.code = code
    }

    /// `base` — its region, calendar, and number and time preferences — speaking this language.
    public func locale(basedOn base: Locale = .autoupdatingCurrent) -> Locale {
        guard base.language.languageCode?.identifier != code else { return base }
        var components = Locale.Components(locale: base)
        components.languageComponents = Locale.Language.Components(
            languageCode: Locale.LanguageCode(code),
            region: base.region
        )
        return Locale(components: components)
    }
}

// MARK: - Shipped Languages
public extension AppLanguage {
    /// Every language the app ships, the development language first.
    static let all = shipped(by: .main)

    static func shipped(by bundle: Bundle) -> [AppLanguage] {
        let development = bundle.developmentLocalization
        let rank = { (code: String) in code == development ? 0 : 1 }
        return bundle.localizations
            .filter { $0 != "Base" }
            .sorted { (rank($0), $0) < (rank($1), $1) }
            .map(AppLanguage.init(code:))
    }

    /// The language iOS opens the app in for `preferences`, the person's languages
    /// most preferred first: the first of `shipped` they read, else the first shipped.
    static func resolved(from preferences: [String], among shipped: [AppLanguage] = all) -> AppLanguage {
        let code = Bundle.preferredLocalizations(from: shipped.map(\.code), forPreferences: preferences).first
        return code.map(AppLanguage.init(code:)) ?? shipped.first ?? AppLanguage(code: "en")
    }
}

// MARK: - Keeping the Choice
public extension AppLanguage {
    /// The key iOS Settings' per-app language writes. Set here, the next launch
    /// opens in the language, system text included.
    static let preferenceKey = "AppleLanguages"

    func keep(in defaults: UserDefaults) {
        defaults.set([code], forKey: Self.preferenceKey)
    }
}
