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
                highlightsGrid
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 24)
                    .animation(.easeOut(duration: 0.5).delay(0.08), value: appeared)
                FeatureComparisonSection()
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 24)
                    .animation(.easeOut(duration: 0.5).delay(0.13), value: appeared)
                pricingSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 24)
                    .animation(.easeOut(duration: 0.5).delay(0.20), value: appeared)
                ctaSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 24)
                    .animation(.easeOut(duration: 0.5).delay(0.28), value: appeared)
                footerSection
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.36), value: appeared)
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
            globeHero
            VStack(spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.accent)
                    Text("GEOGRAFY PREMIUM")
                        .font(.system(size: 11, weight: .black))
                        .tracking(1.5)
                        .foregroundStyle(DesignSystem.Color.accent)
                }
                Text("Master the world")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Unlock every feature and explore geography like never before.")
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
    }

    var globeHero: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.12))
                .frame(width: 110, height: 110)
                .scaleEffect(globePulse ? 1.20 : 0.88)
                .blur(radius: 10)
            Circle()
                .fill(DesignSystem.Color.blue.opacity(0.08))
                .frame(width: 130, height: 130)
                .scaleEffect(globePulse ? 0.92 : 1.14)
                .blur(radius: 14)
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Color.accent.opacity(0.18),
                                DesignSystem.Color.blue.opacity(0.12),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 86, height: 86)
                Image(systemName: "globe.europe.africa.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DesignSystem.Color.accent, DesignSystem.Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(globePulse ? 1.07 : 0.96)
                    .shadow(color: DesignSystem.Color.accent.opacity(0.5), radius: 18, y: 6)
            }
        }
        .frame(height: 130)
    }
}

// MARK: - Highlights Grid

private extension PaywallScreen {
    struct Highlight {
        let icon: String
        let color: Color
        let title: String
        let subtitle: String
    }

    var highlights: [Highlight] {
        [
            Highlight(icon: "questionmark.circle.fill", color: DesignSystem.Color.purple,
                      title: "6 Quiz Types", subtitle: "Flag, capital, reverse, population & more"),
            Highlight(icon: "chart.bar.xaxis", color: DesignSystem.Color.blue,
                      title: "Deep Stats", subtitle: "GDP, languages, government & economy"),
            Highlight(icon: "map.fill", color: DesignSystem.Color.accent,
                      title: "All Map Themes", subtitle: "Continent maps & custom color themes"),
            Highlight(icon: "clock.arrow.circlepath", color: DesignSystem.Color.indigo,
                      title: "Quiz History", subtitle: "Track your progress over time"),
        ]
    }

    var highlightsGrid: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("What's included")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: DesignSystem.Spacing.sm), GridItem(.flexible())],
                spacing: DesignSystem.Spacing.sm
            ) {
                ForEach(Array(highlights.enumerated()), id: \.offset) { index, highlight in
                    highlightCard(highlight, delay: Double(index) * 0.05)
                }
            }
        }
    }

    func highlightCard(_ highlight: Highlight, delay: Double) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(highlight.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: highlight.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(highlight.color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(highlight.title)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(highlight.subtitle)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.easeOut(duration: 0.4).delay(0.10 + delay), value: appeared)
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
                    savingsNote: "$1.67 / mo",
                    isSelected: selectedProductID == SubscriptionService.ProductID.yearly,
                    product: product(for: SubscriptionService.ProductID.yearly),
                    onTap: { selectedProductID = SubscriptionService.ProductID.yearly }
                )
                SubscriptionCard(
                    productID: SubscriptionService.ProductID.lifetime,
                    fallbackPrice: "$49.99",
                    period: "one time",
                    badge: "Pay Once",
                    savingsNote: "Forever",
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
            purchaseButton

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

    var purchaseButton: some View {
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
                } else {
                    Image(systemName: "crown.fill")
                        .font(DesignSystem.Font.subheadline)
                }
                Text(isProcessing ? "Processing…" : subscribeButtonTitle)
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm + 2)
            .background(
                LinearGradient(
                    colors: [DesignSystem.Color.accent, DesignSystem.Color.accentDark],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            )
            .shadow(color: DesignSystem.Color.accent.opacity(0.45), radius: 16, y: 5)
        }
        .buttonStyle(.plain)
        .disabled(isProcessing)
    }

    var subscribeButtonTitle: String {
        switch selectedProductID {
        case SubscriptionService.ProductID.lifetime: "Get Lifetime Access"
        default: "Start Premium Now"
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
                Color(hex: "0B1320"),
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
                        colors: [DesignSystem.Color.accent.opacity(0.20), .clear],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 400, height: 300)
                .blur(radius: 44)
                .offset(x: -60, y: -200)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.blue.opacity(0.14), .clear],
                        center: .center, startRadius: 0, endRadius: 180
                    )
                )
                .frame(width: 360, height: 280)
                .blur(radius: 48)
                .offset(x: 140, y: 100)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.indigo.opacity(0.10), .clear],
                        center: .center, startRadius: 0, endRadius: 160
                    )
                )
                .frame(width: 320, height: 260)
                .blur(radius: 40)
                .offset(x: -100, y: 600)
                .scaleEffect(blobAnimating ? 1.06 : 0.94)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
