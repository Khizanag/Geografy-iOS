import Geografy_Core_DesignSystem
import SwiftUI

public struct ExploreGameRulesSheet: View {
    // MARK: - Body
    public var body: some View {
        scrollContent
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("How to Play")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    CircleCloseButton()
                }
            }
            .presentationDetents([.medium])
    }
}

// MARK: - Subviews
private extension ExploreGameRulesSheet {
    var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                ForEach(ExploreGameRules.sections) { section in
                    rulesSectionView(section)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    func rulesSectionView(_ section: ExploreGameRuleSection) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: section.title, icon: section.icon)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                ForEach(section.items, id: \.self) { item in
                    HStack(alignment: .top, spacing: DesignSystem.Spacing.xs) {
                        Circle()
                            .fill(DesignSystem.Color.accent)
                            .frame(width: 5, height: 5)
                            .padding(.top, 6)
                        Text(item)
                            .font(DesignSystem.Font.subheadline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                    }
                }
            }
        }
    }
}
