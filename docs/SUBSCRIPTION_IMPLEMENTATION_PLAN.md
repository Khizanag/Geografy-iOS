# Subscription Implementation Plan

StoreKit 2 subscription implementation for Geografy. Covers product IDs, pricing, paywall design, entitlements, and feature gating.

---

## Current State

From `Subscription/View/`:
- `PaywallScreen.swift` — paywall UI exists
- `SubscriptionCard.swift` — subscription cards exist
- `FeatureComparisonSection.swift` — free vs. premium comparison
- `SubscriptionService.swift` (in Data/Service) — service layer exists
- **Debug override enabled** for testing (premium always unlocked in debug)

---

## Product Configuration

### Product IDs (App Store Connect)

```swift
enum SubscriptionProductID: String, CaseIterable {
    case monthly = "com.khizanag.geografy.premium.monthly"
    case annual  = "com.khizanag.geografy.premium.annual"
    case lifetime = "com.khizanag.geografy.premium.lifetime"
}
```

### Pricing Tiers

| Product | Price | Value Proposition |
|---------|-------|-------------------|
| Monthly | $1.99/month | Try premium risk-free |
| Annual | $19.99/year (~$1.67/mo) | Save 16% vs monthly |
| Lifetime | $49.99 one-time | Best value for committed learners |

### Subscription Group
- Group name: `Geografy Premium`
- Monthly and Annual are in the same subscription group (mutually exclusive)
- Lifetime is a non-renewing or one-time purchase (separate from the group)

### Free Trial
- Monthly: 3-day free trial
- Annual: 7-day free trial
- Lifetime: No trial (one-time purchase)

---

## StoreKit 2 Implementation

### Product Fetching

```swift
import StoreKit

@Observable
final class SubscriptionService {
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isSubscribed: Bool { !purchasedProductIDs.isEmpty }

    private var transactionListener: Task<Void, Error>?

    init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
        Task { await updatePurchasedProducts() }
    }

    @MainActor
    func loadProducts() async {
        do {
            products = try await Product.products(
                for: SubscriptionProductID.allCases.map { $0.rawValue }
            )
        } catch {
            // Handle — log, show error state
        }
    }
}
```

### Purchase Flow

```swift
extension SubscriptionService {
    @MainActor
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
```

### Transaction Listener (handles renewals, revocations)

```swift
private func listenForTransactions() -> Task<Void, Error> {
    Task.detached {
        for await result in Transaction.updates {
            if let transaction = try? self.checkVerified(result) {
                await self.updatePurchasedProducts()
                await transaction.finish()
            }
        }
    }
}
```

### Entitlement Checking

```swift
@MainActor
func updatePurchasedProducts() async {
    var purchased: Set<String> = []
    for await result in Transaction.currentEntitlements {
        if let transaction = try? checkVerified(result) {
            purchased.insert(transaction.productID)
        }
    }
    purchasedProductIDs = purchased
}
```

### Restore Purchases

```swift
func restorePurchases() async throws {
    try await AppStore.sync()
    await updatePurchasedProducts()
}
```

---

## Feature Gating

### Free vs. Premium Feature Split

| Feature | Free | Premium | Notes |
|---------|------|---------|-------|
| World map, country detail | ✅ | ✅ | Core feature — always free |
| Country list, search | ✅ | ✅ | |
| Basic quiz (flag, capital) | ✅ | ✅ | 5 questions/session free |
| Full quiz (all regions, all types) | ❌ | ✅ | |
| Unlimited quiz sessions | ❌ | ✅ | Free: 3/day |
| Travel tracker | ✅ | ✅ | Mark visited — core feature |
| Travel journal | ❌ | ✅ | Notes, photos |
| Achievements (view) | ✅ | ✅ | |
| Achievements (unlock premium badges) | ❌ | ✅ | |
| Daily challenge | ✅ | ✅ | 1/day free |
| Daily challenge history | ❌ | ✅ | |
| Country comparison | ❌ | ✅ | |
| Continent stats | ❌ | ✅ | |
| Organizations explorer | ✅ | ✅ | Basic; premium unlocks filtering |
| Custom quiz builder | ❌ | ✅ | |
| Flashcards / SRS system | ❌ | ✅ | |
| Learning paths | ❌ | ✅ | |
| Word search, spelling bee | ❌ | ✅ | |
| Geography features explorer | ❌ | ✅ | |
| Flag symbolism, culture | ❌ | ✅ | |
| Multiplayer / challenge room | ❌ | ✅ | |
| Game Center leaderboards | ✅ | ✅ | Viewing free; premium unlocks global boards |
| Ad-free experience | ❌ | ✅ | If ads are ever added |
| Offline access (already offline) | ✅ | ✅ | |

### Implementation Pattern

```swift
// In SubscriptionService
func isFeatureEnabled(_ feature: PremiumFeature) -> Bool {
    #if DEBUG
    return true  // Debug override
    #else
    return isSubscribed || feature.isFree
    #endif
}

enum PremiumFeature: CaseIterable {
    case unlimitedQuiz
    case countryComparison
    case customQuiz
    case flashcards
    case travelJournal
    // etc.

    var isFree: Bool {
        switch self {
        case .unlimitedQuiz, .countryComparison, .customQuiz,
             .flashcards, .travelJournal:
            return false
        }
    }
}
```

### PremiumBadge Component

The `PremiumBadge` component (already in Design/Component) should appear on locked features. Tapping it should trigger the paywall sheet.

---

## Paywall Design Best Practices

### Layout Structure

```
[Close button — top right]

[Hero: app icon + "Geografy Premium"]
[Tagline: "Master the world's geography"]

[Feature highlights — 3-4 key items with icons]
  🗺️ Unlimited quizzes
  🎯 Custom quiz builder
  🏆 Advanced leaderboards
  ✈️ Travel journal

[Plan picker]
  [Annual — BEST VALUE badge] $19.99/year
    7-day free trial
  [Monthly] $1.99/month
    3-day free trial
  [Lifetime] $49.99 once
    One-time payment

[Primary CTA button]
  "Start Free Trial" (if trial available)
  "Get Premium" (if no trial)

[Restore purchases link]
[Privacy Policy | Terms of Service links]
[Legal: "Cancel anytime" / subscription terms]
```

### Psychological Principles
1. **Default select Annual** — has best ROI for the user; leads with value
2. **Free trial CTA** — "Start Free Trial" converts better than "Subscribe"
3. **Lifetime option** — anchors the annual price as cheap by comparison
4. **Feature highlights** — show specific features the user was trying to use
5. **Context-aware paywall** — "Unlock Custom Quiz Builder" when triggered from that screen vs. generic paywall

### Context-Aware Paywall

```swift
// Present with context
coordinator.present(.paywall(context: .customQuiz))

// PaywallScreen uses context to highlight relevant feature
enum PaywallContext {
    case generic
    case unlimitedQuiz
    case customQuiz
    case travelJournal
    case comparison
}
```

---

## Receipt Validation

### Client-Side (StoreKit 2 — Built-in)

StoreKit 2 uses signed JWS transactions verified on-device. No server needed for basic validation:

```swift
// VerificationResult<Transaction> is automatically verified by Apple's servers
// Using checkVerified() pattern above is sufficient for most apps
```

### Server-Side (if backend added later)

```
App → POST /validate → Your Server → Apple's /verifyReceipt → Response
```

For Geografy (no backend currently), client-side StoreKit 2 verification is sufficient. The risk (jailbreak bypass) is acceptable for a geography learning app.

### Sandbox Testing

```swift
// StoreKit Testing in Xcode
// Add StoreKit configuration file: Geografy.storekit
// Products defined there mirror App Store Connect products
// Transactions clear automatically on each test run
```

---

## App Store Connect Setup Checklist

- [ ] Create subscription group: "Geografy Premium"
- [ ] Create products:
  - Monthly ($1.99, 3-day trial)
  - Annual ($19.99, 7-day trial)
  - Lifetime ($49.99, non-consumable or non-renewing)
- [ ] Add subscription description (required for review)
- [ ] Upload paywall screenshot for App Review metadata
- [ ] Configure renewal grace period: 6 days (monthly), 16 days (annual)
- [ ] Set up billing retry: enabled
- [ ] Family sharing: consider enabling for lifetime

---

## Introductory Offers

StoreKit 2 supports three intro offer types:
- **Free trial**: Full access, then billing starts
- **Pay-as-you-go**: Discounted rate for X periods
- **Pay-upfront**: Discounted lump sum for X months

For Geografy, use **free trial** only. Introductory offers are one-time per user.

```swift
// Check if user is eligible for intro offer
extension Product {
    var hasEligibleIntroOffer: Bool {
        get async {
            guard let subscription = self.subscription else { return false }
            return await subscription.isEligibleForIntroOffer
        }
    }
}
```

---

## StoreKit Configuration File (Development)

Create `Geografy.storekit` in Xcode:
```xml
<!-- Products -->
<product type="auto-renewable" id="com.khizanag.geografy.premium.monthly">
    <price tier="2">  <!-- Tier 2 = $1.99 -->
    <subscriptionGroupID>group.geografy.premium</subscriptionGroupID>
    <subscriptionPeriod unit="month" value="1"/>
    <introductoryOffer type="freeTrial" period="3 days"/>
</product>
```

---

## Metrics to Track (for future analytics)

- Paywall impression rate (how often users see it)
- Paywall conversion rate (% who purchase)
- Trial start rate
- Trial conversion rate (% who don't cancel)
- Lifetime vs. subscription split
- Churn rate by plan
- Feature that triggered paywall (context) vs. conversion
