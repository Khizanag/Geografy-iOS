import SwiftUI

struct GeoIconButton: View {
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
                .font(GeoFont.headline)
                .foregroundStyle(isActive ? .white : GeoColors.textPrimary)
                .frame(width: 44, height: 44)
                .background(backgroundColor)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Helpers

private extension GeoIconButton {
    var backgroundColor: Color {
        if isActive {
            GeoColors.accent
        } else {
            Color.black.opacity(0.5)
        }
    }
}
