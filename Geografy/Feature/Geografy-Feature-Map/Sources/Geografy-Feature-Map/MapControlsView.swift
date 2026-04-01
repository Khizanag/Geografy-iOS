import GeografyCore
import GeografyDesign
import SwiftUI

public struct MapControlsView: View {
    @Binding public var showLabels: Bool
    public let onBack: () -> Void

    public init(
        showLabels: Binding<Bool>,
        onBack: @escaping () -> Void
    ) {
        self._showLabels = showLabels
        self.onBack = onBack
    }

    public var body: some View {
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
        mapIconButton(systemImage: "chevron.left", action: onBack)
            .accessibilityLabel("Back")
    }

    var labelsToggleButton: some View {
        mapIconButton(
            systemImage: "textformat",
            isActive: showLabels
        ) {
            showLabels.toggle()
        }
        .accessibilityLabel("Country labels")
        .accessibilityValue(showLabels ? "Shown" : "Hidden")
    }

    func mapIconButton(
        systemImage: String,
        isActive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(isActive ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
                .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
                .background(isActive ? DesignSystem.Color.accent : DesignSystem.Color.overlayScrim)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
