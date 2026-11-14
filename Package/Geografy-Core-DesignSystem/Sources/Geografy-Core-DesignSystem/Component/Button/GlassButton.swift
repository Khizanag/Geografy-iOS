import SwiftUI

public struct GlassButton: View {
    // MARK: - Properties
    private let title: String
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
        _ title: String,
        systemImage: String? = nil,
        role: Role = .primary,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
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
                Label(title, systemImage: systemImage)
            } else {
                Text(title)
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
            Text(title)
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
