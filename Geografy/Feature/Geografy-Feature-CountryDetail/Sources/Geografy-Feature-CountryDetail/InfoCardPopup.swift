import Geografy_Core_DesignSystem
import SwiftUI

public struct InfoCardPopup: View {
    private let icon: String
    private let title: String
    private let value: String
    private let showMapButton: Bool
    private let onClose: () -> Void
    private let onShowMap: () -> Void

    @State private var appeared = false

    public init(
        icon: String,
        title: String,
        value: String,
        showMapButton: Bool = false,
        onClose: @escaping () -> Void,
        onShowMap: @escaping () -> Void = {}
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.showMapButton = showMapButton
        self.onClose = onClose
        self.onShowMap = onShowMap
    }

    public var body: some View {
        ZStack {
            backdrop
            popupCard
                .scaleEffect(appeared ? 1.0 : 0.85)
                .opacity(appeared ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                appeared = true
            }
        }
    }
}

// MARK: - Subviews
private extension InfoCardPopup {
    var backdrop: some View {
        ZStack {
            DesignSystem.Color.overlayScrim
            Rectangle().fill(.ultraThinMaterial)
        }
        .ignoresSafeArea()
        .onTapGesture(perform: onClose)
    }

    var popupCard: some View {
        VStack(spacing: 0) {
            closeButton
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, DesignSystem.Spacing.md)

            iconCircle
                .padding(.bottom, DesignSystem.Spacing.lg)

            Text(title)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.accent)
                .textCase(.uppercase)
                .kerning(1.2)
                .padding(.bottom, DesignSystem.Spacing.xs)

            Text(value)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            if showMapButton {
                mapButton
                    .padding(.top, DesignSystem.Spacing.lg)
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .background {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge)
                        .fill(DesignSystem.Color.cardBackground.opacity(0.85))
                }
        }
        .geoShadow(.elevated)
        .padding(.horizontal, DesignSystem.Spacing.xl)
        .frame(maxWidth: 380)
    }

    var iconCircle: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.12))
                .frame(width: 80, height: 80)
            Image(systemName: icon)
                .font(DesignSystem.Font.iconXL.weight(.medium))
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    var closeButton: some View {
        Button(action: onClose) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.cardBackgroundHighlighted)
                    .frame(width: 30, height: 30)
                Image(systemName: "xmark")
                    .font(DesignSystem.Font.caption.bold())
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }

    var mapButton: some View {
        GeoButton("Show on the map", systemImage: "map", style: .secondary) {
            onShowMap()
        }
    }
}
