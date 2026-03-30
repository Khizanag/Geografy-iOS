import SwiftUI

struct FlagFullScreenView: View {
    @Environment(\.dismiss) private var dismiss

    let countryCode: String
    let countryName: String

    var body: some View {
        ZStack {
            DesignSystem.Color.background
                .ignoresSafeArea()

            flagContent
        }
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
