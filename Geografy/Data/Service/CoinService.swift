import Foundation
import Geografy_Core_Common

@Observable
final class CoinService {
    private(set) var balance: Int
    private(set) var transactions: [CoinTransaction]

    private let balanceKey = "coin_balance"
    private let transactionsKey = "coin_transactions"

    init() {
        self.balance = UserDefaults.standard.integer(forKey: "coin_balance")
        if let data = UserDefaults.standard.data(forKey: "coin_transactions"),
           let decoded = try? JSONDecoder().decode([CoinTransaction].self, from: data) {
            self.transactions = decoded
        } else {
            self.transactions = []
        }
    }

    func earn(_ amount: Int, reason: CoinReason) {
        guard amount > 0 else { return }
        balance += amount
        appendTransaction(amount: amount, reason: reason)
        persist()
    }

    func spend(_ amount: Int, reason: CoinReason) -> Bool {
        guard amount > 0, balance >= amount else { return false }
        balance -= amount
        appendTransaction(amount: -amount, reason: reason)
        persist()
        return true
    }
}

// MARK: - Formatted Balance
extension CoinService {
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: balance)) ?? "\(balance)"
    }

    var recentTransactions: [CoinTransaction] {
        Array(transactions.prefix(5))
    }
}

// MARK: - Persistence
private extension CoinService {
    func appendTransaction(amount: Int, reason: CoinReason) {
        let transaction = CoinTransaction(
            id: UUID(),
            amount: amount,
            reason: reason,
            date: Date(),
            balanceAfter: balance
        )
        transactions.insert(transaction, at: 0)
    }

    func persist() {
        UserDefaults.standard.set(balance, forKey: balanceKey)
        if let data = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(data, forKey: transactionsKey)
        }
    }
}
