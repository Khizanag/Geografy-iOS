import SwiftUI

public struct GlassButton: View {
    // MARK: - Properties
    private let title: Text
    private let systemImage: String?
    private let role: Role
    private let fullWidth: Bool
    private let action: () -> Void

    @State private var pressCount = 0

    public enum Role {
        case primary
        case secondary
        /// Deletes, resets, or signs out: the label is red. Confirm before acting.
        case destructive
    }

    // MARK: - Init
    public init(
        _ title: LocalizedStringKey,
        systemImage: String? = nil,
        role: Role = .primary,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = Text(title)
        self.systemImage = systemImage
        self.role = role
        self.fullWidth = fullWidth
        self.action = action
    }

    /// A title that's already in the reader's language, such as one built with `String(localized:in:)`.
    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        systemImage: String? = nil,
        role: Role = .primary,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = Text(title)
        self.systemImage = systemImage
        self.role = role
        self.fullWidth = fullWidth
        self.action = action
    }

    // MARK: - Body
    /// The screen's one primary action is prominent glass in the accent; every other button is plain glass.
    public var body: some View {
        if role == .primary {
            button
                .buttonStyle(.glassProminent)
                .tint(DesignSystem.Color.accent)
        } else {
            button
                .buttonStyle(.glass)
        }
    }
}

// MARK: - Subviews
private extension GlassButton {
    /// Every press taps lightly, whatever the action does next.
    var button: some View {
        Button {
            pressCount += 1
            action()
        } label: {
            label
                .font(font)
                .foregroundStyle(labelStyle)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .padding(.vertical, DesignSystem.Spacing.xxs)
        }
        .buttonBorderShape(.capsule)
        .haptic(.impact(weight: .light), trigger: pressCount)
    }

    @ViewBuilder
    var label: some View {
        if let systemImage {
            Label {
                title
            } icon: {
                Image(systemName: systemImage)
            }
        } else {
            title
        }
    }

    /// Secondary ranks below primary by weight, not by a grey label that reads as disabled.
    var font: Font {
        switch role {
        case .primary, .destructive: DesignSystem.Font.headline
        case .secondary: DesignSystem.Font.body.weight(.medium)
        }
    }

    /// The prominent style draws its own label colour over the accent; the others name theirs as a style, never a
    /// tint, so a sheet passing over them doesn't dim it.
    var labelStyle: AnyShapeStyle {
        switch role {
        case .primary: AnyShapeStyle(DesignSystem.Color.onAccent)
        case .secondary: AnyShapeStyle(DesignSystem.Color.textPrimary)
        case .destructive: AnyShapeStyle(DesignSystem.Color.destructive)
        }
    }
}
