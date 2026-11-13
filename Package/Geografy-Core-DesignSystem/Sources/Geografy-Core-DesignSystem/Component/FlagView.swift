import Geografy_Core_Common
import SwiftUI

public struct FlagView: View {
    // MARK: - Properties
    let countryCode: String
    var height: CGFloat = DesignSystem.Size.md
    var fixedWidth: Bool = false

    // MARK: - Init
    public init(
        countryCode: String,
        height: CGFloat = DesignSystem.Size.md,
        fixedWidth: Bool = false
    ) {
        self.countryCode = countryCode
        self.height = height
        self.fixedWidth = fixedWidth
    }

    // MARK: - Body
    public var body: some View {
        flagImage
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small / 2, style: .continuous))
            .frame(width: fixedWidth ? slotWidth : nil, height: fixedWidth ? height : nil, alignment: .center)
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
            let size = fittedSize(ratio: ratio)
            Image(uiImage: uiImage)
                .resizable()
                .frame(width: size.width, height: size.height)
        } else {
            Text(fallbackEmoji)
                .font(DesignSystem.Font.title)
        }
    }

    /// The width reserved for each flag when `fixedWidth` is on, so a list's text lines up.
    var slotWidth: CGFloat { height * 1.6 }

    // A fixed-width slot fits wide flags (2:1 and wider) to its width instead of letting them
    // spill past it; flags that fit keep the full height.
    func fittedSize(ratio: CGFloat) -> CGSize {
        let naturalWidth = height * ratio
        guard fixedWidth, naturalWidth > slotWidth else {
            return CGSize(width: naturalWidth, height: height)
        }
        return CGSize(width: slotWidth, height: slotWidth / ratio)
    }

    var fallbackEmoji: String {
        countryCode
            .uppercased()
            .unicodeScalars
            .compactMap { UnicodeScalar(127_397 + $0.value) }
            .map { String($0) }
            .joined()
    }
}
