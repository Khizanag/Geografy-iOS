import SwiftUI

struct FlagFullScreenView: View {
    @Environment(\.dismiss) private var dismiss

    private let flagEmoji: String
    private let countryName: String

    init(flagEmoji: String, countryName: String) {
        self.flagEmoji = flagEmoji
        self.countryName = countryName
    }

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
            Text(flagEmoji)
                .font(DesignSystem.IconSize.flag)

            Text(countryName)
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }
}
