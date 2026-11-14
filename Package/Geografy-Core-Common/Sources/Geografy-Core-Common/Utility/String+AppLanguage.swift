import Foundation

public extension String {
    /// `key` in the language of `locale`: in a view, the `\.locale` environment value,
    /// which follows a language chosen in the app.
    ///
    /// `String(localized:)` keeps the language the app launched in, and passing it `locale:`
    /// only formats with it. Setting the resource's own locale is what changes the language.
    init(localized key: String.LocalizationValue, bundle: Bundle = .main, in locale: Locale) {
        self.init(localized: LocalizedStringResource(key, locale: locale, bundle: .atURL(bundle.bundleURL)))
    }
}
