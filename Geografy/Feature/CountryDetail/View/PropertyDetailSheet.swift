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
            dragIndicator

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
                    GeoButton(mapButtonTitle, systemImage: "map.fill", style: .primary) {
                        onShowMap()
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(background)
        .presentationDetents([.height(supportsMap ? 360 : 300)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(32)
        .presentationBackground(.clear)
    }
}

// MARK: - Subviews

private extension PropertyDetailSheet {
    var dragIndicator: some View {
        Capsule()
            .fill(DesignSystem.Color.textTertiary.opacity(0.4))
            .frame(width: 36, height: 4)
            .padding(.top, DesignSystem.Spacing.sm)
    }

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

    var background: some View {
        RoundedRectangle(cornerRadius: 32)
            .fill(DesignSystem.Color.background)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .strokeBorder(
                        DesignSystem.Color.accent.opacity(0.08),
                        lineWidth: 1
                    )
            )
    }
}
