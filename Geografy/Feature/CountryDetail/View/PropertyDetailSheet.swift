import SwiftUI

struct PropertyDetailSheet: View {
    let icon: String
    let title: String
    let value: String
    let supportsMap: Bool
    let mapButtonTitle: String
    let onShowMap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                iconHeader
                    .padding(.top, DesignSystem.Spacing.lg)

                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text(title)
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.accent)
                        .textCase(.uppercase)
                        .kerning(1.5)

                    Text(value)
                        .font(DesignSystem.Font.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                }

                Spacer(minLength: DesignSystem.Spacing.sm)

                if supportsMap {
                    GlassButton(mapButtonTitle, systemImage: "map.fill", fullWidth: true) {
                        onShowMap()
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .presentationDetents([.height(supportsMap ? 360 : 300)])
    }
}

// MARK: - Subviews

private extension PropertyDetailSheet {
    var iconHeader: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.accent.opacity(0.2),
                            DesignSystem.Color.accent.opacity(0.0),
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 56
                    )
                )
                .frame(width: 112, height: 112)

            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        }
    }

}
