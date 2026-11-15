import SwiftUI

public struct SectionHeaderView: View {
    // MARK: - Properties
    private let title: Text
    public var icon: String?
    public var isNew: Bool = false
    public var action: SectionHeaderAction?

    // MARK: - Init
    public init(
        title: LocalizedStringKey,
        icon: String? = nil,
        isNew: Bool = false,
        action: SectionHeaderAction? = nil
    ) {
        self.title = Text(title)
        self.icon = icon
        self.isNew = isNew
        self.action = action
    }

    /// A title that's already in the reader's language, such as a name or a value from data.
    @_disfavoredOverload
    public init(
        title: some StringProtocol,
        icon: String? = nil,
        isNew: Bool = false,
        action: SectionHeaderAction? = nil
    ) {
        self.title = Text(title)
        self.icon = icon
        self.isNew = isNew
        self.action = action
    }

    // MARK: - Body
    @ViewBuilder
    public var body: some View {
        if let action {
            HStack {
                header
                Spacer(minLength: DesignSystem.Spacing.sm)
                actionButton(action)
            }
        } else {
            header
        }
    }
}

/// A small glass button at the trailing end of a section header, such as "Shuffle" or "Clear".
public struct SectionHeaderAction {
    let title: Text
    let systemImage: String?
    let accessibilityLabel: Text
    let perform: () -> Void

    /// - Parameter accessibilityLabel: What the button does when its title alone is vague; defaults to the title.
    public init(
        _ title: LocalizedStringKey,
        systemImage: String? = nil,
        accessibilityLabel: LocalizedStringKey? = nil,
        perform: @escaping () -> Void
    ) {
        self.title = Text(title)
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel.map { Text($0) } ?? Text(title)
        self.perform = perform
    }
}

// MARK: - Subviews
private extension SectionHeaderView {
    var header: some View {
        extractedContent
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
    }

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
            title
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

    func actionButton(_ action: SectionHeaderAction) -> some View {
        Button(action: action.perform) {
            if let systemImage = action.systemImage {
                Label {
                    action.title
                } icon: {
                    Image(systemName: systemImage)
                }
            } else {
                action.title
            }
        }
        .buttonStyle(.glass)
        .controlSize(.small)
        .accessibilityLabel(action.accessibilityLabel)
    }
}
