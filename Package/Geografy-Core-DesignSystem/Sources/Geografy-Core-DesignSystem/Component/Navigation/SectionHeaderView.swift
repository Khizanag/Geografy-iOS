import SwiftUI

public struct SectionHeaderView: View {
    // MARK: - Properties
    public let title: String
    public var icon: String?
    public var isNew: Bool = false

    // MARK: - Init
    public init(
        title: String,
        icon: String? = nil,
        isNew: Bool = false
    ) {
        self.title = title
        self.icon = icon
        self.isNew = isNew
    }

    // MARK: - Body
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
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .accessibilityHidden(true)
            } else {
                leadingBar
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

    /// Neutral, so a screen's own colors carry meaning and headers don't compete with them.
    var leadingBar: some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(DesignSystem.Color.textTertiary)
            .frame(width: 3, height: 18)
    }
}
