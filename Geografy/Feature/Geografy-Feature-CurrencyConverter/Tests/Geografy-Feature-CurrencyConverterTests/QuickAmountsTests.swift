@testable import Geografy_Feature_CurrencyConverter
import Testing

@Suite("QuickAmounts")
struct QuickAmountsTests {
    @Test("Rows convert each base amount at the rate")
    func convertsAtRate() {
        let rows = QuickAmounts.rows(rate: 0.5)

        #expect(rows.map(\.amount) == QuickAmounts.baseAmounts)
        #expect(rows.map(\.converted) == QuickAmounts.baseAmounts.map { $0 * 0.5 })
    }

    @Test(
        "Weak currencies start at a higher amount",
        arguments: [
            (0.92, 1.0),
            (1.5, 1.0),
            (0.1, 1.0),
            (0.05, 10.0),
            (0.0067, 100.0),
            (0.000024, 10_000.0),
        ]
    )
    func scale(rate: Double, expected: Double) {
        #expect(QuickAmounts.scale(for: rate) == expected)
    }

    @Test("A scaled table starts at the scaled amount")
    func scaledRows() {
        let rows = QuickAmounts.rows(rate: 0.0067)

        #expect(rows.first?.amount == 100)
        #expect(rows.last?.amount == 100_000)
    }

    @Test("No rows for a zero, negative or infinite rate", arguments: [0, -1, Double.infinity, Double.nan])
    func noRowsForInvalidRate(rate: Double) {
        #expect(QuickAmounts.rows(rate: rate).isEmpty)
    }
}
