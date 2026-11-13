import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct CountryStatisticsView: View {
    // MARK: - Properties
    @Environment(WorldBankService.self) private var worldBankService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let countryCode: String

    @State private var selectedCategory: StatCategory = .economy

    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            categoryPicker
            indicatorCards
        }
        .task(id: selectedCategory) {
            await worldBankService.fetch(selectedCategory.indicators, for: countryCode)
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
        .scrollClipDisabled()
    }

    func categoryTab(_ category: StatCategory) -> some View {
        SelectableChip(
            category.title,
            systemImage: category.icon,
            isSelected: selectedCategory == category
        ) {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        }
    }

    var indicatorCards: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(selectedCategory.indicators) { indicator in
                WorldBankIndicatorCard(
                    indicator: indicator,
                    state: worldBankService.state(for: indicator, countryCode: countryCode),
                    cacheAge: worldBankService.cacheAge(for: indicator, countryCode: countryCode),
                    onRetry: { Task { await worldBankService.fetch(indicator, for: countryCode) } }
                )
            }
        }
    }
}
