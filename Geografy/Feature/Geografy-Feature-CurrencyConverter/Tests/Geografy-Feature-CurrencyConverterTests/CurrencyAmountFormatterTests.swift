import Foundation
@testable import Geografy_Feature_CurrencyConverter
import Testing

@Suite("CurrencyAmountFormatter")
struct CurrencyAmountFormatterTests {
    private static let english = Locale(identifier: "en_US")
    private static let german = Locale(identifier: "de_DE")

    @Test(
        "Two decimals, four below 1",
        arguments: [
            (1_234.5, "1,234.50"),
            (0.92, "0.9200"),
            (0.0067, "0.0067"),
            (0, "0.00"),
        ]
    )
    func formatsConvertedValues(value: Double, expected: String) {
        #expect(CurrencyAmountFormatter.string(for: value, locale: Self.english) == expected)
    }

    @Test("Input amounts have no grouping and no trailing zeros")
    func formatsInputAmounts() {
        #expect(CurrencyAmountFormatter.inputString(for: 1_000, locale: Self.english) == "1000")
        #expect(CurrencyAmountFormatter.inputString(for: 2.5, locale: Self.english) == "2.5")
        #expect(CurrencyAmountFormatter.inputString(for: 2.5, locale: Self.german) == "2,5")
    }

    @Test(
        "Reads plain numbers with the locale's separators",
        arguments: [
            ("12.5", english, 12.5),
            ("1,000.25", english, 1_000.25),
            ("12,5", german, 12.5),
            ("1.000,25", german, 1_000.25),
            (" 7 ", english, 7),
        ]
    )
    func parsesAmounts(text: String, locale: Locale, expected: Double) {
        #expect(CurrencyAmountFormatter.amount(from: text, locale: locale) == expected)
    }

    @Test("Rejects anything that isn't a plain number", arguments: ["", "abc", "1.2.3", "-5", "0x10", "inf", "nan"])
    func rejectsInvalidInput(text: String) {
        #expect(CurrencyAmountFormatter.amount(from: text, locale: Self.english) == nil)
    }

    @Test("An input string reads back as the same amount")
    func roundTrips() {
        for locale in [Self.english, Self.german] {
            let text = CurrencyAmountFormatter.inputString(for: 1_234.5, locale: locale)
            #expect(CurrencyAmountFormatter.amount(from: text, locale: locale) == 1_234.5)
        }
    }
}
