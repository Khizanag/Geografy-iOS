import Foundation
import Geografy_Core_Common

/// What a theme tile previews before a puzzle starts: how many words the theme hides and a few of them.
struct WordSearchThemeSummary: Equatable {
    static let defaultSampleSize = 3

    let wordCount: Int
    let sampleWords: [String]

    init(theme: WordSearchTheme, sampleSize: Int = defaultSampleSize) {
        self.init(words: theme.words, sampleSize: sampleSize)
    }

    /// Samples are spread evenly across the list, so a mixed theme such as Continents & Oceans shows both kinds.
    init(words: [String], sampleSize: Int = defaultSampleSize) {
        let count = min(max(sampleSize, 0), words.count)
        wordCount = words.count
        sampleWords = (0..<count).map { position in
            Self.displayName(words[position * words.count / count])
        }
    }
}

// MARK: - Helpers
private extension WordSearchThemeSummary {
    // The grid spells words in capitals; the preview reads better as names.
    static func displayName(_ word: String) -> String {
        word.capitalized(with: Locale(identifier: "en_US_POSIX"))
    }
}
