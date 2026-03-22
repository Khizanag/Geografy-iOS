import StoreKit
import SwiftUI

struct PaywallScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionService.self) private var subscriptionService

    @State private var selectedProductID = SubscriptionService.ProductID.yearly
    @State private var isProcessing = false
    @State private var appeared = false
    @State private var globePulse = false
    @State private var blobAnimating = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                ambientBlobs
                scrollContent
            }
            .navigationTitle("Geografy Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CircleCloseButton()
                }
            }
        }
        .task {
            await subscriptionService.loadProducts()
            await subscriptionService.checkEntitlements()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appeared = true }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                globePulse = true
            }
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                blobAnimating = true
            }
        }
    }
}

// MARK: - Scroll Content

private extension PaywallScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                heroSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 24)
                    .animation(.easeOut(duration: 0.5), value: appeared)
                FeatureComparisonSection()
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 24)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
                pricingSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 24)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
                ctaSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 24)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
                footerSection
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: appeared)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.sm)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }
}

// MARK: - Hero

private extension PaywallScreen {
    var heroSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .scaleEffect(globePulse ? 1.15 : 0.90)
                    .blur(radius: 8)
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.08))
                    .frame(width: 120, height: 120)
                    .scaleEffect(globePulse ? 0.95 : 1.10)
                    .blur(radius: 12)
                Image(systemName: "globe.europe.africa.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DesignSystem.Color.accent, DesignSystem.Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(globePulse ? 1.06 : 0.97)
                    .shadow(color: DesignSystem.Color.accent.opacity(0.4), radius: 16, y: 6)
            }
            .frame(height: 120)

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Unlock Geografy Premium")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Master geography with advanced quizzes,\ndeep country stats, and more.")
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
    }
}

// MARK: - Pricing

private extension PaywallScreen {
    var pricingSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Choose Your Plan")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            HStack(spacing: DesignSystem.Spacing.xs) {
                SubscriptionCard(
                    productID: SubscriptionService.ProductID.monthly,
                    fallbackPrice: "$1.99",
                    period: "per month",
                    badge: nil,
                    savingsNote: nil,
                    isSelected: selectedProductID == SubscriptionService.ProductID.monthly,
                    product: product(for: SubscriptionService.ProductID.monthly),
                    onTap: { selectedProductID = SubscriptionService.ProductID.monthly }
                )
                SubscriptionCard(
                    productID: SubscriptionService.ProductID.yearly,
                    fallbackPrice: "$19.99",
                    period: "per year",
                    badge: "Best Value",
                    savingsNote: "Save 16%",
                    isSelected: selectedProductID == SubscriptionService.ProductID.yearly,
                    product: product(for: SubscriptionService.ProductID.yearly),
                    onTap: { selectedProductID = SubscriptionService.ProductID.yearly }
                )
                SubscriptionCard(
                    productID: SubscriptionService.ProductID.lifetime,
                    fallbackPrice: "$49.99",
                    period: "one time",
                    badge: "Pay Once",
                    savingsNote: nil,
                    isSelected: selectedProductID == SubscriptionService.ProductID.lifetime,
                    product: product(for: SubscriptionService.ProductID.lifetime),
                    onTap: { selectedProductID = SubscriptionService.ProductID.lifetime }
                )
            }
        }
    }

    func product(for id: String) -> Product? {
        subscriptionService.products.first { $0.id == id }
    }
}

// MARK: - CTA

private extension PaywallScreen {
    var ctaSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Button {
                guard !isProcessing else { return }
                if let selectedProduct = product(for: selectedProductID) {
                    isProcessing = true
                    Task {
                        await subscriptionService.purchase(selectedProduct)
                        isProcessing = false
                        if subscriptionService.isPremium {
                            dismiss()
                        }
                    }
                }
            } label: {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    }
                    Text(isProcessing ? "Processing…" : subscribeButtonTitle)
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    LinearGradient(
                        colors: [DesignSystem.Color.accent, DesignSystem.Color.accentDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                )
                .shadow(color: DesignSystem.Color.accent.opacity(0.4), radius: 12, y: 4)
            }
            .buttonStyle(.plain)
            .disabled(isProcessing)

            if let error = subscriptionService.purchaseError {
                Text(error)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.error)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task { await subscriptionService.restorePurchases() }
            } label: {
                Text("Restore Purchases")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .underline()
            }
            .buttonStyle(.plain)
        }
    }

    var subscribeButtonTitle: String {
        switch selectedProductID {
        case SubscriptionService.ProductID.lifetime: "Get Lifetime Access"
        default: "Subscribe Now"
        }
    }
}

// MARK: - Footer

private extension PaywallScreen {
    var footerSection: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Text("Subscription auto-renews unless cancelled at least 24 hours before period ends.")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .multilineTextAlignment(.center)
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text("Terms of Service")
                    .underline()
                Text("·")
                Text("Privacy Policy")
                    .underline()
            }
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
}

// MARK: - Background

private extension PaywallScreen {
    var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "0D1520"),
                DesignSystem.Color.background,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.accent.opacity(0.22), .clear],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 400, height: 300)
                .blur(radius: 40)
                .offset(x: -60, y: -200)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.blue.opacity(0.15), .clear],
                        center: .center, startRadius: 0, endRadius: 180
                    )
                )
                .frame(width: 360, height: 280)
                .blur(radius: 44)
                .offset(x: 140, y: 100)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.indigo.opacity(0.12), .clear],
                        center: .center, startRadius: 0, endRadius: 160
                    )
                )
                .frame(width: 320, height: 260)
                .blur(radius: 36)
                .offset(x: -100, y: 500)
                .scaleEffect(blobAnimating ? 1.06 : 0.94)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
