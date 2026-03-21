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
            iconHeader
                .padding(.top, DesignSystem.Spacing.xl)

            Text(title)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.accent)
                .textCase(.uppercase)
                .kerning(1.5)
                .padding(.top, DesignSystem.Spacing.md)

            Text(value)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, DesignSystem.Spacing.xs)
                .padding(.horizontal, DesignSystem.Spacing.xl)

            Spacer()

            if supportsMap {
                GeoButton(mapButtonTitle, systemImage: "map.fill", style: .primary) {
                    onShowMap()
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Color.background)
        .presentationDetents([.height(supportsMap ? 360 : 300)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
        .presentationBackground(DesignSystem.Color.background)
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
                            DesignSystem.Color.accent.opacity(0.25),
                            DesignSystem.Color.accent.opacity(0.0),
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 52
                    )
                )
                .frame(width: 104, height: 104)

            Image(systemName: icon)
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }
}
