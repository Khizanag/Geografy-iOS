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
            GeoColors.background
                .ignoresSafeArea()

            flagContent
        }
        .onTapGesture { dismiss() }
    }
}

// MARK: - Subviews

private extension FlagFullScreenView {
    var flagContent: some View {
        VStack(spacing: GeoSpacing.lg) {
            Text(flagEmoji)
                .font(.system(size: 200))

            Text(countryName)
                .font(GeoFont.largeTitle)
                .foregroundStyle(GeoColors.textPrimary)
        }
    }
}
