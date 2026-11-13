import Geografy_Core_Common
@testable import Geografy_Feature_WordSearch
import Testing

@Suite("WordSearchThemeSummary")
struct WordSearchThemeSummaryTests {
    @Test("Samples are spread across the list, not taken from the front")
    func spreadsSamples() {
        let summary = WordSearchThemeSummary(words: ["A", "B", "C", "D", "E", "F", "G", "H"], sampleSize: 3)

        #expect(summary.sampleWords == ["A", "C", "F"])
    }

    @Test("Samples read as names rather than grid capitals")
    func capitalizesSamples() {
        let summary = WordSearchThemeSummary(words: ["PARIS", "NEW YORK"], sampleSize: 2)

        #expect(summary.sampleWords == ["Paris", "New York"])
    }

    @Test("Word count covers every word, not just the samples")
    func countsAllWords() {
        let summary = WordSearchThemeSummary(words: ["ONE", "TWO", "THREE", "FOUR"], sampleSize: 2)

        #expect(summary.wordCount == 4)
        #expect(summary.sampleWords.count == 2)
    }

    @Test("A sample size larger than the list returns every word in order")
    func shortList() {
        let summary = WordSearchThemeSummary(words: ["LIMA", "ROME"], sampleSize: 5)

        #expect(summary.sampleWords == ["Lima", "Rome"])
    }

    @Test("Empty lists and non-positive sizes return no samples", arguments: [
        ([String](), 3),
        (["OSLO", "RIGA"], 0),
        (["OSLO", "RIGA"], -2),
    ])
    func noSamples(words: [String], sampleSize: Int) {
        let summary = WordSearchThemeSummary(words: words, sampleSize: sampleSize)

        #expect(summary.sampleWords.isEmpty)
        #expect(summary.wordCount == words.count)
    }

    @Test("Every theme previews distinct words from its own list", arguments: WordSearchTheme.allCases)
    func everyTheme(theme: WordSearchTheme) {
        let summary = WordSearchThemeSummary(theme: theme)
        let themeWords = Set(theme.words.map { $0.lowercased() })

        #expect(summary.sampleWords.count == WordSearchThemeSummary.defaultSampleSize)
        #expect(Set(summary.sampleWords).count == summary.sampleWords.count)
        #expect(summary.sampleWords.allSatisfy { themeWords.contains($0.lowercased()) })
        #expect(summary.wordCount == theme.words.count)
    }

    @Test("Continents & Oceans previews both a continent and an ocean")
    func mixedTheme() {
        let summary = WordSearchThemeSummary(theme: .continents)

        #expect(summary.sampleWords.contains("Africa"))
        #expect(summary.sampleWords.contains("Atlantic"))
    }
}
