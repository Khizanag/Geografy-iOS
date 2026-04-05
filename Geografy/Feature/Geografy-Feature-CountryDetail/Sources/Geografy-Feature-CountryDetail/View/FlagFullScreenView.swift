import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import SwiftUI

public struct FlagFullScreenView: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator

    public let countryCode: String
    public let countryName: String

    // MARK: - Body
    public var body: some View {
        Button { coordinator.dismiss() } label: {
            flagContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }
}

// MARK: - Subviews
private extension FlagFullScreenView {
    var flagContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            FlagView(countryCode: countryCode, height: 120)
                .shadow(radius: DesignSystem.Spacing.sm)

            Text(countryName)
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }
}
