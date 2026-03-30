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
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xs)

            Spacer()
        }
    }
}

// MARK: - Subviews
private extension MapControlsView {
    var backButton: some View {
        IconButton(systemImage: "chevron.left", action: onBack)
            .accessibilityLabel("Back")
    }

    var labelsToggleButton: some View {
        IconButton(
            systemImage: "textformat",
            isActive: showLabels
        ) {
            showLabels.toggle()
        }
        .accessibilityLabel("Country labels")
        .accessibilityValue(showLabels ? "Shown" : "Hidden")
    }
}
