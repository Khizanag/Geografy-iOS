import SwiftUI

struct ComingSoonView: View {
    let icon: String

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            Spacer()

            Image(systemName: icon)
                .font(GeoIconSize.xxLarge)
                .foregroundStyle(GeoColors.accent.opacity(0.6))

            Text("Coming Soon")
                .font(GeoFont.body)
                .foregroundStyle(GeoColors.textSecondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GeoColors.background)
    }
}
