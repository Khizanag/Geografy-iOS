import Foundation

enum CurrencyAmountFormatter {
    /// A converted value: two decimals, or four below 1 so small rates don't round to zero.
    static func string(for value: Double, locale: Locale = .current) -> String {
        let digits = value != 0 && abs(value) < 1 ? 4 : 2
        return value.formatted(.number.precision(.fractionLength(digits)).locale(locale))
    }

    /// An amount to put in the input field: no grouping, and decimals only when it has them.
    static func inputString(for value: Double, locale: Locale = .current) -> String {
        value.formatted(.number.grouping(.never).precision(.fractionLength(0...2)).locale(locale))
    }

    /// Reads what the person typed, accepting the locale's separators. Nil when it isn't a plain number.
    static func amount(from text: String, locale: Locale = .current) -> Double? {
        let decimalSeparator = locale.decimalSeparator ?? "."
        let groupingSeparator = locale.groupingSeparator ?? ","
        var normalized = text.trimmingCharacters(in: .whitespaces)
        if groupingSeparator != decimalSeparator {
            normalized = normalized.replacingOccurrences(of: groupingSeparator, with: "")
        }
        normalized = normalized.replacingOccurrences(of: decimalSeparator, with: ".")

        let isPlainNumber = !normalized.isEmpty
            && normalized.allSatisfy { $0.isASCII && ($0.isNumber || $0 == ".") }
        guard isPlainNumber, let value = Double(normalized), value.isFinite else { return nil }
        return value
    }
}
