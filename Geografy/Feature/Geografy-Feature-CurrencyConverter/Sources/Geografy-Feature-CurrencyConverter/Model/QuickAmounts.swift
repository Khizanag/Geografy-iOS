import Foundation

/// One line of the quick-amounts table: "100 USD = 92.00 EUR".
struct QuickAmount: Identifiable, Equatable, Sendable {
    let amount: Double
    let converted: Double

    var id: Double { amount }
}

enum QuickAmounts {
    static let baseAmounts: [Double] = [1, 5, 10, 50, 100, 500, 1_000]

    static func rows(rate: Double) -> [QuickAmount] {
        guard rate.isFinite, rate > 0 else { return [] }
        let scale = scale(for: rate)
        return baseAmounts.map { base in
            let amount = base * scale
            return QuickAmount(amount: amount, converted: amount * rate)
        }
    }

    /// Weak currencies start higher, so 1 JPY → 0.0067 USD becomes 100 JPY → 0.67 USD.
    static func scale(for rate: Double) -> Double {
        guard rate < 0.1 else { return 1 }
        return pow(10, floor(log10(1 / rate)))
    }
}
