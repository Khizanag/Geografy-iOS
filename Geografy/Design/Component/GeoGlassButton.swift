import SwiftUI

struct GeoGlassButton: View {
    private let title: String
    private let systemImage: String?
    private let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: GeoSpacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(GeoFont.headline)
                }

                Text(title)
                    .font(GeoFont.headline)
            }
            .foregroundStyle(GeoColors.textPrimary)
            .padding(.horizontal, GeoSpacing.lg)
            .padding(.vertical, GeoSpacing.sm)
        }
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}
