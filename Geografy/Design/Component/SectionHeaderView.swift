import SwiftUI

struct SectionHeaderView: View {
    let title: String
    var icon: String?
    var isNew: Bool = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            if let icon {
                Image(systemName: icon)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.accent)
            } else {
                accentBar
            }
            Text(title)
                .font(DesignSystem.Font.title2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            if isNew {
                NewBadge()
            }
        }
    }
}

// MARK: - Subviews
private extension SectionHeaderView {
    var accentBar: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(DesignSystem.Color.accent)
            .frame(width: 3, height: 18)
    }
}
