import Geografy_Core_DesignSystem
import SwiftUI

public struct FlagFullScreenView: View {
    @Environment(\.dismiss) private var dismiss

    public let countryCode: String
    public let countryName: String

    public var body: some View {
        flagContent
            .background(DesignSystem.Color.background.ignoresSafeArea())
        .onTapGesture { dismiss() }
    }
}

// MARK: - Subviews
private extension FlagFullScreenView {
    var flagContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            FlagView(countryCode: countryCode, height: DesignSystem.Size.hero)
                .shadow(radius: DesignSystem.Spacing.sm)

            Text(countryName)
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }
}
