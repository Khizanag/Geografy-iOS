import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

struct CoinStoreScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CoinService.self) private var coinService

    @State private var showAllTransactions = false
    @State private var earnInfoExpanded = false
    @State private var selectedPack: CoinPack?

    var body: some View {
        scrollContent
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Coins")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedPack) { pack in
                CoinPackPreviewSheet(pack: pack)
            }
    }
}

// MARK: - Subviews
private extension CoinStoreScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                balanceSection
                transactionSection
                coinPacksSection
                earnInfoSection
            }
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }
}

// MARK: - Balance
private extension CoinStoreScreen {
    var balanceSection: some View {
        CoinBalanceView()
            .padding(.top, DesignSystem.Spacing.lg)
    }
}

// MARK: - Transaction History
private extension CoinStoreScreen {
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
            SectionHeaderView(title: "History")
            Spacer()
            if coinService.transactions.count > 5 {
                seeAllButton
            }
        }
    }

    var seeAllButton: some View {
        Button { showAllTransactions = true } label: {
            Text("See All")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    var emptyTransactionsView: some View {
        CardView {
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
        CardView {
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
}

// MARK: - Coin Packs
private extension CoinStoreScreen {
    var coinPacksSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Get More Coins")
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
                        selectedPack = pack
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Earn Info
private extension CoinStoreScreen {
    var earnInfoSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            earnInfoHeader
                .padding(.horizontal, DesignSystem.Spacing.md)

            if earnInfoExpanded {
                earnInfoItems
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                            removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                        )
                    )
            }
        }
    }

    var earnInfoHeader: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                earnInfoExpanded.toggle()
            }
        } label: {
            HStack {
                SectionHeaderView(title: "How to Earn Coins")
                Spacer()
                Image(systemName: "chevron.down")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .rotationEffect(.degrees(earnInfoExpanded ? -180 : 0))
            }
        }
        .buttonStyle(.plain)
    }

    var earnInfoItems: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            earnInfoRow(
                icon: "checkmark.circle.fill",
                color: DesignSystem.Color.success,
                title: "Complete Quizzes",
                detail: "Earn coins for every quiz you finish"
            )
            earnInfoRow(
                icon: "calendar.badge.checkmark",
                color: DesignSystem.Color.accent,
                title: "Daily Login",
                detail: "Log in every day to collect bonus coins"
            )
            earnInfoRow(
                icon: "trophy.fill",
                color: DesignSystem.Color.warning,
                title: "Unlock Achievements",
                detail: "Earn rewards for reaching milestones"
            )
            earnInfoRow(
                icon: "arrow.up.circle.fill",
                color: DesignSystem.Color.indigo,
                title: "Level Up",
                detail: "Get coin bonuses when you gain a new level"
            )
        }
    }

    func earnInfoRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(color.opacity(0.15))
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .strokeBorder(color.opacity(0.3), lineWidth: 1)
                Image(systemName: icon)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(color)
            }
            .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(title)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(detail)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }

            Spacer(minLength: 0)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}
