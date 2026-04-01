import SwiftUI

public struct SectionHeaderView: View {
    public let title: String
    public var icon: String?
    public var isNew: Bool = false

    public init(
        title: String,
        icon: String? = nil,
        isNew: Bool = false
    ) {
        self.title = title
        self.icon = icon
        self.isNew = isNew
    }

    public var body: some View {
        extractedContent
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Subviews
private extension SectionHeaderView {
    var extractedContent: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            if let icon {
                Image(systemName: icon)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .accessibilityHidden(true)
            } else {
                accentBar
                    .accessibilityHidden(true)
            }
            Text(title)
                .font(DesignSystem.Font.title2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            #if !os(tvOS)
            if isNew {
                NewBadge()
            }
            #endif
        }
    }

    var accentBar: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(DesignSystem.Color.accent)
            .frame(width: 3, height: 18)
    }
}
