import Foundation

// MARK: - Population Formatting
public extension Int {
    func formatPopulation() -> String {
        let value = Double(self)
        return if value >= 1_000_000_000 {
            String(format: "%.1f billion", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            String(format: "%.1f million", value / 1_000_000)
        } else {
            NumberFormatter.decimal.string(from: NSNumber(value: self)) ?? "\(self)"
        }
    }
}

// MARK: - Area, GDP & Currency Formatting
public extension Double {
    func formatArea() -> String {
        if self >= 1_000_000 {
            return String(format: "%.2f million km²", self / 1_000_000)
        } else {
            let formatted = NumberFormatter.decimal.string(from: NSNumber(value: self)) ?? "\(self)"
            return "\(formatted) km²"
        }
    }

    func formatGDP() -> String {
        if self >= 1_000_000_000_000 {
            String(format: "$%.1f trillion", self / 1_000_000_000_000)
        } else if self >= 1_000_000_000 {
            String(format: "$%.1f billion", self / 1_000_000_000)
        } else if self >= 1_000_000 {
            String(format: "$%.1f million", self / 1_000_000)
        } else {
            "$\(NumberFormatter.decimal.string(from: NSNumber(value: self)) ?? "\(self)")"
        }
    }

    func formatCurrency() -> String {
        NumberFormatter.currency.string(from: NSNumber(value: self)) ?? "$\(self)"
    }
}

// MARK: - Number Formatters
private extension NumberFormatter {
    static let decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}
