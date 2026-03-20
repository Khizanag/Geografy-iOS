import SwiftUI

struct InfoCardPopup: View {
    private let title: String
    private let value: String
    private let showMapButton: Bool
    private let onClose: () -> Void
    private let onShowMap: () -> Void

    init(
        title: String,
        value: String,
        showMapButton: Bool = false,
        onClose: @escaping () -> Void,
        onShowMap: @escaping () -> Void = {}
    ) {
        self.title = title
        self.value = value
        self.showMapButton = showMapButton
        self.onClose = onClose
        self.onShowMap = onShowMap
    }

    var body: some View {
        ZStack {
            dimmedBackground
            popupCard
        }
    }
}

// MARK: - Subviews

private extension InfoCardPopup {
    var dimmedBackground: some View {
        Color.black.opacity(0.6)
            .ignoresSafeArea()
            .onTapGesture(perform: onClose)
    }

    var popupCard: some View {
        GeoCard(cornerRadius: DesignSystem.CornerRadius.large) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                headerRow
                valueSection
                if showMapButton {
                    mapButton
                }
            }
            .padding(DesignSystem.Spacing.xl)
            .frame(maxWidth: DesignSystem.Size.section)
        }
    }

    var headerRow: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textSecondary)

            Spacer()

            GeoIconButton(systemImage: "xmark") {
                onClose()
            }
        }
    }

    var valueSection: some View {
        Text(value)
            .font(DesignSystem.Font.title)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var mapButton: some View {
        GeoButton("Show on the map", systemImage: "map", style: .secondary) {
            onShowMap()
        }
    }
}
