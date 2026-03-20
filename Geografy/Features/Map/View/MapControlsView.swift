import SwiftUI

struct MapControlsView: View {
    @Binding var showLabels: Bool
    let onBack: () -> Void

    var body: some View {
        VStack {
            HStack {
                backButton
                Spacer()
                labelsToggleButton
            }
            .padding(.horizontal, GeoSpacing.md)
            .padding(.top, GeoSpacing.xs)

            Spacer()
        }
    }
}

// MARK: - Subviews

private extension MapControlsView {
    var backButton: some View {
        GeoIconButton(systemImage: "chevron.left", action: onBack)
    }

    var labelsToggleButton: some View {
        GeoIconButton(
            systemImage: "textformat",
            isActive: showLabels
        ) {
            showLabels.toggle()
        }
    }
}
