import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct CountryStatisticsView: View {
    // MARK: - Properties
    @Environment(WorldBankService.self) private var worldBankService

    public let countryCode: String

    @State private var selectedCategory: StatCategory = .economy

    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            categoryPicker
            indicatorCards
        }
        .task {
            await worldBankService.prefetchAll(for: countryCode)
        }
    }
}

// MARK: - Subviews
private extension CountryStatisticsView {
    var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(StatCategory.allCases) { category in
                    categoryTab(category)
                }
            }
        }
        .contentMargins(.horizontal, DesignSystem.Spacing.md, for: .scrollContent)
    }

    func categoryTab(_ category: StatCategory) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: category.icon)
                    .font(DesignSystem.Font.caption2)
                    .accessibilityHidden(true)
                Text(category.title)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(selectedCategory == category ? .semibold : .regular)
            }
            .foregroundStyle(
                selectedCategory == category
                    ? DesignSystem.Color.onAccent
                    : DesignSystem.Color.textSecondary
            )
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                selectedCategory == category
                    ? DesignSystem.Color.accent
                    : DesignSystem.Color.cardBackground
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    var indicatorCards: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(selectedCategory.indicators) { indicator in
                WorldBankIndicatorCard(
                    indicator: indicator,
                    state: worldBankService.state(for: indicator, countryCode: countryCode),
                    cacheAge: worldBankService.cacheAge(for: indicator, countryCode: countryCode)
                )
            }
        }
    }
}
