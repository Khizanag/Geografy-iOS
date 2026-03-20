import SwiftUI

struct FlagView: View {
    let countryCode: String
    var height: CGFloat = DesignSystem.Size.md

    var body: some View {
        flagImage
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small / 2))
    }
}

// MARK: - Subviews

private extension FlagView {
    @ViewBuilder
    var flagImage: some View {
        let assetName = "Flags/\(countryCode.uppercased())"

        if UIImage(named: assetName) != nil {
            Image(assetName)
                .resizable()
                .scaledToFit()
        } else {
            Text(fallbackEmoji)
                .font(DesignSystem.Font.title)
        }
    }

    var fallbackEmoji: String {
        countryCode
            .uppercased()
            .unicodeScalars
            .compactMap { UnicodeScalar(127397 + $0.value) }
            .map { String($0) }
            .joined()
    }
}
