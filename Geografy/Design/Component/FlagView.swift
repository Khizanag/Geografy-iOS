import SwiftUI

struct FlagView: View {
    let countryCode: String
    var height: CGFloat = DesignSystem.Size.md

    var body: some View {
        flagImage
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small / 2))
            .accessibilityLabel("Flag of \(countryCode.uppercased())")
    }
}

// MARK: - Subviews
private extension FlagView {
    @ViewBuilder
    var flagImage: some View {
        let assetName = "Flags/\(countryCode.uppercased())"

        if let uiImage = UIImage(named: assetName) {
            let ratio = FlagAspectRatio.ratio(for: countryCode)
                ?? (uiImage.size.width / uiImage.size.height)
            Image(uiImage: uiImage)
                .resizable()
                .frame(width: height * ratio, height: height)
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
