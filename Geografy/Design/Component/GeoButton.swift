import SwiftUI

struct GeoButton: View {
    enum Style {
        case primary
        case secondary
        case text
    }

    private let title: String
    private let systemImage: String?
    private let style: Style
    private let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        style: Style = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subviews
private extension GeoButton {
    var label: some View {
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
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay {
            if style == .secondary {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .strokeBorder(DesignSystem.Color.accent, lineWidth: 1.5)
            }
        }
    }
}

// MARK: - Helpers
private extension GeoButton {
    var foregroundColor: Color {
        switch style {
        case .primary: .white
        case .secondary: DesignSystem.Color.accent
        case .text: DesignSystem.Color.accent
        }
    }

    var backgroundColor: Color {
        switch style {
        case .primary: DesignSystem.Color.accent
        case .secondary: .clear
        case .text: .clear
        }
    }
}
