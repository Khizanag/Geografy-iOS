import Observation
import StoreKit

@Observable
@MainActor
final class SubscriptionService {
    enum ProductID {
        static let monthly = "com.khizanag.geografy.premium.monthly"
        static let annual = "com.khizanag.geografy.premium.annual"
        static let lifetime = "com.khizanag.geografy.premium.lifetime"
        static let all = [monthly, annual, lifetime]
    }

    #if DEBUG
    /// Enable premium for testing. Set to `true` to unlock all features.
    private static let debugPremiumOverride = true
    #endif

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isLoading = false
    private(set) var purchaseError: String?

    var isPremium: Bool {
        #if DEBUG
        if Self.debugPremiumOverride { return true }
        #endif
        return !purchasedProductIDs.isEmpty
    }

    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = listenForTransactions()
        Task { await checkEntitlements() }
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let loaded = try await Product.products(for: ProductID.all)
            products = loaded.sorted { sortOrder($0) < sortOrder($1) }
        } catch {
            products = []
        }
    }

    func purchase(_ product: Product) async {
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await checkEntitlements()
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func restorePurchases() async {
        purchaseError = nil
        do {
            try await AppStore.sync()
            await checkEntitlements()
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func checkEntitlements() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               ProductID.all.contains(transaction.productID) {
                purchased.insert(transaction.productID)
            }
        }
        purchasedProductIDs = purchased
    }
}

// MARK: - Helpers

private extension SubscriptionService {
    func sortOrder(_ product: Product) -> Int {
        switch product.id {
        case ProductID.monthly:  0
        case ProductID.annual:   1
        case ProductID.lifetime: 2
        default:                 3
        }
    }

    func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.checkEntitlements()
                }
            }
        }
    }
}
