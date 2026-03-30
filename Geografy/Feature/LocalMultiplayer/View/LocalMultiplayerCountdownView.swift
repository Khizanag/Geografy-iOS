import SwiftUI

struct LocalMultiplayerCountdownView: View {
    let coordinator: LocalMultiplayerCoordinator

    var body: some View {
        Group {
            if case .countdown(let remaining) = coordinator.state {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    Text(remaining > 0 ? "\(remaining)" : "GO!")
                        .font(DesignSystem.Font.displayXL)
                        .fontWeight(.black)
                        .foregroundStyle(
                            remaining > 0
                                ? DesignSystem.Color.textPrimary
                                : DesignSystem.Color.accent
                        )
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: remaining)

                    Text("Get ready...")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { AmbientBlobsView(.standard) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }
}
