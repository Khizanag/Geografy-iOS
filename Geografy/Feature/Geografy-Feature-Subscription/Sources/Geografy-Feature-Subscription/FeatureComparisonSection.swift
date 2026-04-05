import Geografy_Core_DesignSystem
import SwiftUI

public struct FeatureComparisonSection: View {
    // MARK: - Properties
    @State private var appeared = false

    // MARK: - Body
    public var body: some View {
        mainContent
            .padding(DesignSystem.Spacing.md)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
            .onAppear {
                appeared = true
            }
    }
}

// MARK: - Subviews
private extension FeatureComparisonSection {
    var mainContent: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            columnHeaders
            Divider()
                .background(DesignSystem.Color.dividerSubtle)
            featureRows
        }
    }

    var columnHeaders: some View {
        HStack {
            Text("Features")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Free")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .frame(width: 44)
            Text("Premium")
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: 68)
        }
    }

    var featureRows: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(Array(allFeatures.enumerated()), id: \.offset) { index, item in
                featureRow(item, index: index)
            }
        }
    }

    func featureRow(_ item: FeatureItem, index: Int) -> some View {
        HStack {
            Text(item.name)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            checkIcon(included: item.isFree)
                .frame(width: 44)
            checkIcon(included: true)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: 68)
        }
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -12)
        .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.04), value: appeared)
    }

    func checkIcon(included: Bool) -> some View {
        Image(systemName: included ? "checkmark.circle.fill" : "xmark.circle.fill")
            .font(DesignSystem.Font.callout)
            .foregroundStyle(included ? DesignSystem.Color.success : DesignSystem.Color.textTertiary)
    }
}

// MARK: - Model
private extension FeatureComparisonSection {
    struct FeatureItem {
        let name: String
        let isFree: Bool
    }

    var freeFeatures: [FeatureItem] {
        [
            FeatureItem(name: "World map", isFree: true),
            FeatureItem(name: "Flag, capital, area, population", isFree: true),
            FeatureItem(name: "Flag Quiz & Capital Quiz", isFree: true),
            FeatureItem(name: "Travel tracker", isFree: true),
            FeatureItem(name: "Favorites", isFree: true),
            FeatureItem(name: "XP & leveling", isFree: true),
            FeatureItem(name: "Achievements & Game Center", isFree: true),
        ]
    }

    var premiumFeatures: [FeatureItem] {
        [
            FeatureItem(name: "All 6 quiz types", isFree: false),
            FeatureItem(name: "GDP, currency, languages", isFree: false),
            FeatureItem(name: "Government & organizations", isFree: false),
            FeatureItem(name: "Quiz history log", isFree: false),
            FeatureItem(name: "All map themes", isFree: false),
            FeatureItem(name: "Continent maps", isFree: false),
        ]
    }

    var allFeatures: [FeatureItem] { freeFeatures + premiumFeatures }
}
