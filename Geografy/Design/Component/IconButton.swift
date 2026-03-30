import SwiftUI

struct IconButton: View {
    private let systemImage: String
    private let isActive: Bool
    private let action: () -> Void

    init(
        systemImage: String,
        isActive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.isActive = isActive
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(isActive ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
                .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
                .background(backgroundColor)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Helpers
private extension IconButton {
    var backgroundColor: Color {
        if isActive {
            DesignSystem.Color.accent
        } else {
            DesignSystem.Color.overlayScrim
        }
    }
}
