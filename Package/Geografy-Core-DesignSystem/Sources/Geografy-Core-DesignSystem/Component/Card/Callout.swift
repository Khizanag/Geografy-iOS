import SwiftUI

/// A note set apart from the reading: a banner, a notice, a status. One panel of system glass, tinted faintly in
/// its tone, with the card corner, so every callout in the app looks alike. With an action it's a button, and the
/// glass answers the press.
public struct Callout<Content: View>: View {
    // MARK: - Properties
    @State private var pressCount = 0

    private let tint: Color
    private let action: (() -> Void)?
    private let content: Content

    // MARK: - Init
    /// - Parameters:
    ///   - tint: The callout's tone, such as warning or success.
    ///   - action: What a tap does; nil for a callout that only informs.
    public init(
        tint: Color,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.tint = tint
        self.action = action
        self.content = content()
    }

    // MARK: - Body
    public var body: some View {
        if let action {
            Button {
                pressCount += 1
                action()
            } label: {
                panel(isInteractive: true)
            }
            .buttonStyle(.plain)
            .haptic(.impact(weight: .light), trigger: pressCount)
        } else {
            panel(isInteractive: false)
        }
    }
}

// MARK: - Subviews
private extension Callout {
    func panel(isInteractive: Bool) -> some View {
        let glass = Glass.regular.tint(tint.opacity(DesignSystem.Opacity.tint))
        return content
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect(cornerRadius: DesignSystem.CornerRadius.card))
            .glassEffect(
                isInteractive ? glass.interactive() : glass,
                in: .rect(cornerRadius: DesignSystem.CornerRadius.card)
            )
    }
}
