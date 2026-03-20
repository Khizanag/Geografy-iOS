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
        GeoCard(cornerRadius: GeoCornerRadius.large) {
            VStack(spacing: GeoSpacing.lg) {
                headerRow
                valueSection
                if showMapButton {
                    mapButton
                }
            }
            .padding(GeoSpacing.xl)
            .frame(maxWidth: 320)
        }
    }

    var headerRow: some View {
        HStack {
            Text(title)
                .font(GeoFont.title2)
                .foregroundStyle(GeoColors.textSecondary)

            Spacer()

            GeoIconButton(systemImage: "xmark") {
                onClose()
            }
        }
    }

    var valueSection: some View {
        Text(value)
            .font(GeoFont.title)
            .foregroundStyle(GeoColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var mapButton: some View {
        GeoButton("Show on the map", systemImage: "map", style: .secondary) {
            onShowMap()
        }
    }
}
