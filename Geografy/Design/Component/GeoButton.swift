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
        HStack(spacing: GeoSpacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(GeoFont.headline)
            }

            Text(title)
                .font(GeoFont.headline)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, GeoSpacing.lg)
        .padding(.vertical, GeoSpacing.sm)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: GeoCornerRadius.medium))
        .overlay {
            if style == .secondary {
                RoundedRectangle(cornerRadius: GeoCornerRadius.medium)
                    .strokeBorder(GeoColors.accent, lineWidth: 1.5)
            }
        }
    }
}

// MARK: - Helpers

private extension GeoButton {
    var foregroundColor: Color {
        switch style {
        case .primary: .white
        case .secondary: GeoColors.accent
        case .text: GeoColors.accent
        }
    }

    var backgroundColor: Color {
        switch style {
        case .primary: GeoColors.accent
        case .secondary: .clear
        case .text: .clear
        }
    }
}
