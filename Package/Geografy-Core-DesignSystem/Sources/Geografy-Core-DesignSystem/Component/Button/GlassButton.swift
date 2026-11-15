import SwiftUI

public struct GlassButton: View {
    // MARK: - Properties
    private let title: Text
    private let systemImage: String?
    private let role: Role
    private let fullWidth: Bool
    private let action: () -> Void

    public enum Role {
        case primary
        case secondary
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
    public var body: some View {
        if fullWidth {
            Button(action: action) {
                label
            }
            .buttonStyle(.glass)
        } else {
            Button(action: action) {
                label
            }
            .glassEffect(.regular.interactive(), in: .capsule)
        }
    }
}

// MARK: - Subviews
private extension GlassButton {
    @ViewBuilder
    var label: some View {
        if fullWidth {
            fullWidthLabel
        } else {
            inlineLabel
        }
    }

    var fullWidthLabel: some View {
        Group {
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
        .font(font)
        .foregroundStyle(DesignSystem.Color.textPrimary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .hoverEffect(.highlight)
    }

    var inlineLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            title
        }
        .font(font)
        .foregroundStyle(DesignSystem.Color.textPrimary)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .hoverEffect(.highlight)
    }

    /// Secondary ranks below primary by weight, not by a grey label that reads as disabled.
    var font: Font {
        switch role {
        case .primary: DesignSystem.Font.headline
        case .secondary: DesignSystem.Font.body.weight(.medium)
        }
    }
}
