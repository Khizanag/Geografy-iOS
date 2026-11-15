import SwiftUI

/// What a screen shows when it has nothing to list yet: an icon, a title, a line on why,
/// and, when there's a way out, the button that takes it.
///
/// Every empty, locked, or signed-out state uses this, so none is a dead end and all read alike.
public struct EmptyStateView: View {
    // MARK: - Properties
    private let icon: String
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey
    private let actionTitle: LocalizedStringKey?
    private let action: (() -> Void)?

    // MARK: - Init
    /// - Parameters:
    ///   - actionTitle: The button's label; give it with `action`, or leave both out when there's nothing to do.
    public init(
        icon: String,
        title: LocalizedStringKey,
        message: LocalizedStringKey,
        actionTitle: LocalizedStringKey? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    // MARK: - Body
    public var body: some View {
        ContentUnavailableView {
            Label {
                Text(title)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        } description: {
            Text(message)
        } actions: {
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(DesignSystem.Font.headline)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                }
                .buttonStyle(.glassProminent)
                .tint(DesignSystem.Color.accent)
            }
        }
    }
}
