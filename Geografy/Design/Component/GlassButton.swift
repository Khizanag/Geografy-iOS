import Geografy_Core_DesignSystem
import SwiftUI

struct GlassButton: View {
    private let title: String
    private let systemImage: String?
    private let role: Role
    private let fullWidth: Bool
    private let action: () -> Void

    enum Role {
        case primary
        case secondary
    }

    init(
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

    var body: some View {
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
        .font(DesignSystem.Font.headline)
        .foregroundStyle(foregroundColor)
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .hoverEffect(.highlight)
    }

    var inlineLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(DesignSystem.Font.headline)
            }
            Text(title)
                .font(DesignSystem.Font.headline)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .hoverEffect(.highlight)
    }

    var foregroundColor: Color {
        switch role {
        case .primary: DesignSystem.Color.textPrimary
        case .secondary: DesignSystem.Color.textSecondary
        }
    }
}
