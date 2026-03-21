import SwiftUI

struct CoinStoreScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CoinService.self) private var coinService

    @State private var showAllTransactions = false
    @State private var earnInfoExpanded = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    balanceSection
                    transactionSection
                    coinPacksSection
                    earnInfoSection
                }
                .padding(.bottom, DesignSystem.Spacing.xxl)
            }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Coins")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    closeButton
                }
            }
        }
    }
}

// MARK: - Subviews

private extension CoinStoreScreen {
    var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark.circle.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .buttonStyle(.plain)
    }

    var balanceSection: some View {
        CoinBalanceView()
            .padding(.top, DesignSystem.Spacing.lg)
    }

    // MARK: Transaction History

    var transactionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            transactionHeader
            if coinService.transactions.isEmpty {
                emptyTransactionsView
            } else {
                transactionList
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var transactionHeader: some View {
        HStack {
            sectionLabel("History", icon: "clock.fill")
            Spacer()
            if coinService.transactions.count > 5 {
                Button { showAllTransactions = true } label: {
                    Text("See All")
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.accent)
                }
            }
        }
    }

    var emptyTransactionsView: some View {
        GeoCard {
            HStack {
                Spacer()
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "tray")
                        .font(DesignSystem.IconSize.large)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                    Text("No transactions yet")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    Text("Complete quizzes and log in daily to earn coins")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(DesignSystem.Spacing.lg)
                Spacer()
            }
        }
    }

    var transactionList: some View {
        GeoCard {
            VStack(spacing: 0) {
                let displayedTransactions = showAllTransactions
                    ? coinService.transactions
                    : coinService.recentTransactions

                ForEach(Array(displayedTransactions.enumerated()), id: \.element.id) { index, transaction in
                    CoinTransactionRow(transaction: transaction)
                        .padding(.horizontal, DesignSystem.Spacing.md)

                    if index < displayedTransactions.count - 1 {
                        Divider()
                            .padding(.leading, DesignSystem.Spacing.xxl + DesignSystem.Spacing.md)
                    }
                }
            }
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
    }

    // MARK: Coin Packs

    var coinPacksSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionLabel("Get More Coins", icon: "plus.circle.fill")
                .padding(.horizontal, DesignSystem.Spacing.md)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                ],
                spacing: DesignSystem.Spacing.sm
            ) {
                ForEach(CoinPack.allPacks) { pack in
                    CoinPackCard(pack: pack) {
                        handlePurchase(pack)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    // MARK: Earn Info

    var earnInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Button { withAnimation(.spring(response: 0.3)) { earnInfoExpanded.toggle() } } label: {
                HStack {
                    sectionLabel("How to Earn Coins", icon: "info.circle.fill")
                    Spacer()
                    Image(systemName: earnInfoExpanded ? "chevron.up" : "chevron.down")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, DesignSystem.Spacing.md)

            if earnInfoExpanded {
                GeoCard {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        earnRow(icon: "checkmark.circle.fill", title: "Complete Quizzes", detail: "Earn coins for every quiz you finish")
                        earnRow(icon: "calendar.badge.checkmark", title: "Daily Login", detail: "Log in every day to collect bonus coins")
                        earnRow(icon: "trophy.fill", title: "Unlock Achievements", detail: "Earn rewards for reaching milestones")
                        earnRow(icon: "arrow.up.circle.fill", title: "Level Up", detail: "Get coin bonuses when you gain a new level")
                    }
                    .padding(DesignSystem.Spacing.md)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Helpers

private extension CoinStoreScreen {
    func sectionLabel(_ title: String, icon: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(title)
                .font(DesignSystem.Font.title2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    func earnRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.warning)
                .frame(width: DesignSystem.Size.md)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(title)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(detail)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
    }

    func handlePurchase(_ pack: CoinPack) {
        coinService.earn(pack.coins, reason: .purchase)
    }
}
