import Observation
import StoreKit

@Observable
@MainActor
final class SubscriptionService {
    enum ProductID {
        static let monthly = "com.khizanag.geografy.premium.monthly"
        static let yearly = "com.khizanag.geografy.premium.yearly"
        static let lifetime = "com.khizanag.geografy.premium.lifetime"
        static let all = [monthly, yearly, lifetime]
    }

    private(set) var products: [Product] = []
    private(set) var isPremium = false
    private(set) var isLoading = false
    private(set) var purchaseError: String?

    init() {
        Task { @MainActor [weak self] in
            for await _ in Transaction.updates {
                await self?.checkEntitlements()
            }
        }
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
        var hasPremium = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               ProductID.all.contains(transaction.productID) {
                hasPremium = true
            }
        }
        isPremium = hasPremium
    }
}

// MARK: - Helpers

private extension SubscriptionService {
    func sortOrder(_ product: Product) -> Int {
        switch product.id {
        case ProductID.monthly:  0
        case ProductID.yearly:   1
        case ProductID.lifetime: 2
        default:                 3
        }
    }
}
